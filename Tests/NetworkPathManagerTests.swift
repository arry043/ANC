import Foundation

/// Unit test suite for `NetworkPathManager` and lifecycle behavior.
public enum NetworkPathManagerTests {
    public static func run() async throws -> Int {
        var count = 0

        // Test 1: Start monitoring and initial state delivery
        let mockProvider = MockPathMonitorProvider()
        let manager = NetworkPathManager(provider: mockProvider, initialState: .unsatisfied)

        let initialRunning = await manager.isMonitoring
        assert(!initialRunning, "Manager must not be monitoring before startMonitoring()")

        try await manager.startMonitoring()
        let runningAfterStart = await manager.isMonitoring
        assert(runningAfterStart, "Manager must be monitoring after startMonitoring()")
        assert(mockProvider.startCount == 1, "Provider start must be called once")
        assert(mockProvider.isRunning, "Provider must be running")
        count += 1

        // Test 2: Idempotent startMonitoring()
        try await manager.startMonitoring()
        assert(mockProvider.startCount == 1, "Subsequent startMonitoring() must not create duplicate monitors")
        count += 1

        // Test 3: Path state change delivery through stream
        let stream = await manager.pathStateStream
        var receivedStates: [NetworkPathState] = []

        let collectorTask = Task {
            for await state in stream {
                receivedStates.append(state)
                if receivedStates.count >= 2 {
                    break
                }
            }
        }

        // Simulate Wi-Fi connection from provider
        mockProvider.simulatePathUpdate(.satisfiedWiFi)
        _ = await collectorTask.value

        let current = await manager.currentPathState
        assert(current == .satisfiedWiFi, "currentPathState must update to satisfiedWiFi")
        assert(receivedStates.contains(.satisfiedWiFi), "Stream must emit satisfiedWiFi update")
        count += 1

        // Test 4: Duplicate state suppression
        mockProvider.simulatePathUpdate(.satisfiedWiFi)
        let currentStateAfterDuplicate = await manager.currentPathState
        assert(currentStateAfterDuplicate == .satisfiedWiFi, "State should remain unchanged")
        count += 1

        // Test 5: Stop monitoring
        await manager.stopMonitoring()
        let isRunningAfterStop = await manager.isMonitoring
        assert(!isRunningAfterStop, "Manager must not be monitoring after stopMonitoring()")
        assert(mockProvider.cancelCount == 1, "Provider must be cancelled once")
        assert(!mockProvider.isRunning, "Provider should not be running")
        count += 1

        // Test 6: Idempotent stopMonitoring()
        await manager.stopMonitoring()
        assert(mockProvider.cancelCount == 1, "Subsequent stopMonitoring() must be a no-op")
        count += 1

        // Test 7: Restart after stop
        try await manager.startMonitoring()
        let isRunningAfterRestart = await manager.isMonitoring
        assert(isRunningAfterRestart, "Manager must be monitoring after restart")
        assert(mockProvider.startCount == 2, "Provider must be started again on restart")
        count += 1

        // Test 8: Stale callback rejection (callback from old session)
        // Calling handlePathUpdate with old session ID (0)
        await manager.handlePathUpdate(.unsatisfied, sessionID: 0)
        let stateAfterStale = await manager.currentPathState
        assert(stateAfterStale == .satisfiedWiFi, "State must not change from stale callback")
        count += 1

        // Teardown
        await manager.stopMonitoring()

        return count
    }
}
