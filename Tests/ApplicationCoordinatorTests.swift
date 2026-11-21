import Foundation

/// Mock implementation of `PreferencesStoring` for coordinator unit testing.
public actor MockPreferencesStore: PreferencesStoring {
    public var storedPreferences: AppPreferences
    public var loadCount: Int = 0
    public var saveCount: Int = 0

    public init(initialPreferences: AppPreferences = .default) {
        self.storedPreferences = initialPreferences
    }

    public func loadPreferences() async -> AppPreferences {
        loadCount += 1
        return storedPreferences
    }

    public func savePreferences(_ preferences: AppPreferences) async throws {
        saveCount += 1
        self.storedPreferences = preferences
    }
}

/// Mock implementation of `NetworkMonitoring` for coordinator unit testing.
public actor MockNetworkMonitor: NetworkMonitoring {
    public var isMonitoring: Bool = false
    public var currentSnapshot: NetworkSnapshot? = nil
    public var currentPathState: NetworkPathState = .unsatisfied
    public var startCount: Int = 0
    public var stopCount: Int = 0

    private var pathContinuations: [UUID: AsyncStream<NetworkPathState>.Continuation] = [:]
    private var snapshotContinuations: [UUID: AsyncStream<NetworkSnapshot>.Continuation] = [:]

    public var pathStateStream: AsyncStream<NetworkPathState> {
        AsyncStream { continuation in
            let id = UUID()
            continuation.yield(self.currentPathState)
            self.pathContinuations[id] = continuation
        }
    }

    public var snapshotStream: AsyncStream<NetworkSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            if let snap = self.currentSnapshot {
                continuation.yield(snap)
            }
            self.snapshotContinuations[id] = continuation
        }
    }

    public func simulatePathUpdate(_ state: NetworkPathState) {
        currentPathState = state
        for continuation in pathContinuations.values {
            continuation.yield(state)
        }
    }

    public func simulateSnapshotUpdate(_ snapshot: NetworkSnapshot?) {
        currentSnapshot = snapshot
        if let snap = snapshot {
            for continuation in snapshotContinuations.values {
                continuation.yield(snap)
            }
        }
    }

    public func startMonitoring() async throws {
        startCount += 1
        isMonitoring = true
    }

    public func stopMonitoring() async {
        stopCount += 1
        isMonitoring = false
        for continuation in pathContinuations.values {
            continuation.finish()
        }
        pathContinuations.removeAll()
        for continuation in snapshotContinuations.values {
            continuation.finish()
        }
        snapshotContinuations.removeAll()
    }
}

/// Unit test suite for `ApplicationCoordinator` and mock protocol interactions.
public enum ApplicationCoordinatorTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        // Test 1: Coordinator initialization with initial defaults
        let mockStore = MockPreferencesStore()
        let mockMonitor = MockNetworkMonitor()
        let coordinator = ApplicationCoordinator(
            preferencesStore: mockStore,
            networkMonitor: mockMonitor
        )
        assert(!coordinator.isRunning, "Coordinator must not be running before start()")
        assert(coordinator.preferences == .default, "Initial preferences must equal default")
        assert(coordinator.pathState == .unsatisfied, "Initial pathState must equal unsatisfied")
        assert(coordinator.dominantDirection == .download, "Initial dominantDirection must be download")
        count += 1

        // Test 2: Coordinator start() loads preferences, initiates monitor, and syncs pathState
        await coordinator.start()
        assert(coordinator.isRunning, "Coordinator must be running after start()")
        let loadCount = await mockStore.loadCount
        let startCount = await mockMonitor.startCount
        assert(loadCount == 1, "Preferences must be loaded exactly once during start()")
        assert(startCount == 1, "Monitoring must be started exactly once")
        count += 1

        // Test 3: Idempotent start()
        await coordinator.start()
        let loadCount2 = await mockStore.loadCount
        assert(loadCount2 == 1, "Subsequent start() call while running must be a no-op")
        count += 1

        // Test 4: updatePreferences() saves and updates published state
        let updated = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: true
        )
        try await coordinator.updatePreferences(updated)
        assert(coordinator.preferences == updated, "Published preferences must reflect updated value")
        let saveCount = await mockStore.saveCount
        let saved = await mockStore.storedPreferences
        assert(saveCount == 1, "Store saveCount must increment")
        assert(saved == updated, "Saved preferences in store must match updated values")
        count += 1

        // Test 5: Live path update propagation from monitor to coordinator
        await mockMonitor.simulatePathUpdate(.satisfiedWiFi)
        // Allow brief async propagation
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.pathState == .satisfiedWiFi, "Coordinator pathState must update to satisfiedWiFi")
        count += 1

        // Test 6: Snapshot propagation from monitor to coordinator with satisfied path
        let wifi = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)
        let snap1 = NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap1)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.currentSnapshot?.receivedBytes == 1_000_000, "Coordinator currentSnapshot must update")
        assert(coordinator.speedResult == .baselineEstablished, "First snapshot establishes baseline")
        assert(coordinator.latestMeasurement == nil, "Initial baseline produces no speed measurement")
        count += 1

        // Test 7: Second snapshot calculates speed and updates latestMeasurement
        let snap2 = NetworkSnapshot(
            receivedBytes: 1_500_000,
            transmittedBytes: 750_000,
            monotonicTimeNanoseconds: 2_000_000_000, // 1s later
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap2)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.speedResult.isCalculated, "Second snapshot must calculate speed")
        if let m = coordinator.latestMeasurement {
            assert(m.downloadBytesPerSecond == 500_000, "Download speed must be 500,000 B/s")
            assert(m.uploadBytesPerSecond == 250_000, "Upload speed must be 250,000 B/s")
            assert(m.elapsedSeconds == 1.0, "Elapsed seconds must be 1.0")
            assert(coordinator.dominantDirection == .download, "Dominant direction should be download")
        } else {
            assertionFailure("Expected latestMeasurement on coordinator")
        }
        count += 1

        // Test 8: Dominant direction switching via consecutive upload snapshots
        // snap3: delta DL 10k, UL 1,000k -> candidate is upload (sample 1)
        let snap3 = NetworkSnapshot(
            receivedBytes: 1_510_000,
            transmittedBytes: 1_750_000,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap3)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.dominantDirection == .download, "First upload sample should not trigger switch yet")

        // snap4: delta DL 10k, UL 1,000k -> sample 2 confirms switch to upload
        let snap4 = NetworkSnapshot(
            receivedBytes: 1_520_000,
            transmittedBytes: 2_750_000,
            monotonicTimeNanoseconds: 4_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap4)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.dominantDirection == .upload, "Second consecutive upload sample must switch dominant direction to upload")
        count += 1

        // Test 9: Disconnection clears speed measurement, resets baseline, and reverts dominantDirection to download
        await mockMonitor.simulatePathUpdate(.unsatisfied)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.pathState == .unsatisfied, "Coordinator pathState must update to unsatisfied")
        assert(coordinator.speedResult == .noActivePath, "Speed result must be noActivePath when disconnected")
        assert(coordinator.latestMeasurement == nil, "latestMeasurement must be nil when disconnected")
        assert(coordinator.dominantDirection == .download, "dominantDirection must reset to download on disconnection")
        count += 1

        // Test 10: stop() terminates monitoring, clears state, and resets dominantDirection
        await coordinator.stop()
        assert(!coordinator.isRunning, "Coordinator must not be running after stop()")
        assert(coordinator.currentSnapshot == nil, "Coordinator currentSnapshot must be nil after stop()")
        assert(coordinator.speedResult == .noActivePath, "Speed result must be noActivePath after stop")
        assert(coordinator.latestMeasurement == nil, "latestMeasurement must be nil after stop")
        assert(coordinator.dominantDirection == .download, "dominantDirection must be download after stop")
        let stopCount = await mockMonitor.stopCount
        let isMon = await mockMonitor.isMonitoring
        assert(stopCount == 1, "Monitor must receive exactly one stop call")
        assert(!isMon, "Monitor state must be false")
        count += 1

        return count
    }
}
