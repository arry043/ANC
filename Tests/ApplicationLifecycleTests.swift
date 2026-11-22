import Foundation

/// Comprehensive unit test suite for application lifecycle management, startup coordination,
/// shutdown handling, and single monitoring pipeline invariants.
public enum ApplicationLifecycleTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        // ---------------------------------------------------------------------
        // Test 1: Initial coordinator state before start()
        // ---------------------------------------------------------------------
        let mockStore = MockPreferencesStore()
        let mockMonitor = MockNetworkMonitor()
        let coordinator = ApplicationCoordinator(
            preferencesStore: mockStore,
            networkMonitor: mockMonitor
        )

        assert(coordinator.lifecycleState == .notStarted, "Coordinator initial state must be .notStarted")
        assert(!coordinator.isRunning, "Coordinator must not be running initially")
        assert(coordinator.speedResult == .noActivePath, "Initial speedResult must be .noActivePath")
        assert(coordinator.latestMeasurement == nil, "Initial latestMeasurement must be nil")
        assert(coordinator.currentSnapshot == nil, "Initial currentSnapshot must be nil")
        assert(coordinator.dominantDirection == .download, "Initial dominantDirection must be .download")
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Startup coordination from initial state
        // ---------------------------------------------------------------------
        await coordinator.start()
        assert(coordinator.lifecycleState == .running, "State must transition to .running after start()")
        assert(coordinator.isRunning, "isRunning must be true after start()")
        let loadCount = await mockStore.loadCount
        let startCount = await mockMonitor.startCount
        assert(loadCount == 1, "Preferences must be loaded exactly once during start()")
        assert(startCount == 1, "Network monitor must be started exactly once")
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Repeated startup requests are idempotent (single pipeline guarantee)
        // ---------------------------------------------------------------------
        await coordinator.start()
        await coordinator.start()
        let loadCountAfter = await mockStore.loadCount
        let startCountAfter = await mockMonitor.startCount
        assert(loadCountAfter == 1, "Subsequent start calls must not reload preferences")
        assert(startCountAfter == 1, "Subsequent start calls must not invoke monitor start again")
        assert(coordinator.lifecycleState == .running, "Lifecycle state must remain .running")
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Stop before start is safe and idempotent
        // ---------------------------------------------------------------------
        let unstartedCoordinator = ApplicationCoordinator(
            preferencesStore: MockPreferencesStore(),
            networkMonitor: MockNetworkMonitor()
        )
        assert(unstartedCoordinator.lifecycleState == .notStarted, "Must be .notStarted")
        await unstartedCoordinator.stop()
        assert(unstartedCoordinator.lifecycleState == .notStarted, "Stop before start must remain safe no-op")
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Normal stop cancels tasks and resets state
        // ---------------------------------------------------------------------
        // Simulate active connection and measurement before stop
        await mockMonitor.simulatePathUpdate(.satisfiedWiFi)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let wifi = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)
        let snap1 = NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap1)
        try? await Task.sleep(nanoseconds: 10_000_000)

        await coordinator.stop()
        assert(coordinator.lifecycleState == .stopped, "State must transition to .stopped after stop()")
        assert(!coordinator.isRunning, "isRunning must be false after stop()")
        assert(coordinator.speedResult == .noActivePath, "speedResult must reset to .noActivePath")
        assert(coordinator.latestMeasurement == nil, "latestMeasurement must be nil after stop")
        assert(coordinator.currentSnapshot == nil, "currentSnapshot must be nil after stop")
        assert(coordinator.dominantDirection == .download, "dominantDirection must reset to .download")
        let stopCount = await mockMonitor.stopCount
        assert(stopCount == 1, "Monitor must receive exactly one stop call")
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: Repeated stop requests are safe and idempotent
        // ---------------------------------------------------------------------
        await coordinator.stop()
        await coordinator.stop()
        let stopCountAfter = await mockMonitor.stopCount
        assert(stopCountAfter == 1, "Subsequent stop calls must not invoke monitor stop again")
        assert(coordinator.lifecycleState == .stopped, "Lifecycle state must remain .stopped")
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: Start after stop re-establishes clean baseline
        // ---------------------------------------------------------------------
        await coordinator.start()
        assert(coordinator.lifecycleState == .running, "State must return to .running on restart")
        assert(coordinator.isRunning, "isRunning must be true on restart")
        assert(coordinator.speedResult == .baselineEstablished || coordinator.speedResult == .noActivePath, "Speed result must establish fresh baseline without residual calculation")
        assert(coordinator.latestMeasurement == nil, "Latest measurement must be nil on fresh restart")
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: Disconnection does not crash coordinator or disrupt lifecycle
        // ---------------------------------------------------------------------
        await mockMonitor.simulatePathUpdate(.unsatisfied)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.lifecycleState == .running, "Coordinator must stay in .running state during disconnection")
        assert(coordinator.pathState == .unsatisfied, "pathState must reflect unsatisfied")
        assert(coordinator.speedResult == .noActivePath, "speedResult must be .noActivePath")
        count += 1

        await coordinator.stop()

        // ---------------------------------------------------------------------
        // Test 9: NetworkPathManager single sampling task and pipeline enforcement
        // ---------------------------------------------------------------------
        let mockProvider = MockPathMonitorProvider()
        let pathManager = NetworkPathManager(provider: mockProvider)

        let initialMonitoring = await pathManager.isMonitoring
        let initialSampling = await pathManager.isSamplingTaskActive
        assert(!initialMonitoring, "PathManager must not be monitoring initially")
        assert(!initialSampling, "Sampling task must not be active initially")

        try await pathManager.startMonitoring()
        let postStartMonitoring = await pathManager.isMonitoring
        let postStartSampling = await pathManager.isSamplingTaskActive
        assert(postStartMonitoring, "PathManager must be monitoring after start")
        assert(postStartSampling, "Sampling task must be active after start")
        assert(mockProvider.startCount == 1, "Provider startMonitoring must be called once")

        // Repeated start calls on NetworkPathManager
        try await pathManager.startMonitoring()
        try await pathManager.startMonitoring()
        assert(mockProvider.startCount == 1, "Repeated startMonitoring calls must not restart provider")
        let repeatedSampling = await pathManager.isSamplingTaskActive
        assert(repeatedSampling, "Single sampling task remains active")
        count += 1

        // ---------------------------------------------------------------------
        // Test 10: NetworkPathManager cancellation cleans up task and state
        // ---------------------------------------------------------------------
        await pathManager.stopMonitoring()
        let postStopMonitoring = await pathManager.isMonitoring
        let postStopSampling = await pathManager.isSamplingTaskActive
        let postStopSnapshot = await pathManager.currentSnapshot
        assert(!postStopMonitoring, "isMonitoring must be false after stop")
        assert(!postStopSampling, "Sampling task must be cancelled after stop")
        assert(mockProvider.cancelCount == 1, "Provider cancelMonitoring must be called once")
        assert(postStopSnapshot == nil, "currentSnapshot must be nil after stop")

        // Repeated stop calls
        await pathManager.stopMonitoring()
        assert(mockProvider.cancelCount == 1, "Subsequent stopMonitoring calls must be safe no-ops")
        count += 1

        return count
    }
}
