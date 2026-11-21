import Foundation

/// Integration test suite for `NetworkPathManager` snapshot generation and interface selection.
public enum NetworkSnapshotIntegrationTests {
    public static func run() async throws -> Int {
        var count = 0

        let mockPathProvider = MockPathMonitorProvider()
        let mockInterfaceProvider = MockNetworkInterfaceProvider(statistics: [
            NetworkInterfaceStatistics(
                name: "en0",
                type: .wifi,
                receivedBytes: 123_456,
                transmittedBytes: 65_432,
                isUp: true,
                isRunning: true,
                isLoopback: false,
                isVirtual: false
            )
        ])

        let manager = NetworkPathManager(
            provider: mockPathProvider,
            interfaceProvider: mockInterfaceProvider,
            interfaceSelector: NetworkInterfaceSelector(),
            initialState: NetworkPathState(
                status: .satisfied,
                availableInterfaceTypes: [.wifi],
                activeInterfaceName: "en0",
                activeInterfaceType: .wifi,
                isExpensive: false,
                isConstrained: false
            )
        )

        // Test 1: Start monitoring initializes snapshot
        try await manager.startMonitoring()
        let isMon = await manager.isMonitoring
        assert(isMon, "Manager must be monitoring")
        let snapshot1 = await manager.currentSnapshot
        assert(snapshot1 != nil, "Snapshot must be populated on start with satisfied path")
        if let s = snapshot1 {
            assert(s.interface?.name == "en0", "Snapshot interface must be en0")
            assert(s.receivedBytes == 123_456, "Snapshot receivedBytes must match mock stats")
            assert(s.transmittedBytes == 65_432, "Snapshot transmittedBytes must match mock stats")
            assert(s.monotonicTimeNanoseconds > 0, "Snapshot monotonic timestamp must be positive")
        }
        count += 1

        // Test 2: Sample current snapshot updates cumulative values
        await mockInterfaceProvider.setStatistics([
            NetworkInterfaceStatistics(
                name: "en0",
                type: .wifi,
                receivedBytes: 200_000,
                transmittedBytes: 100_000,
                isUp: true,
                isRunning: true,
                isLoopback: false,
                isVirtual: false
            )
        ])
        let snapshot2 = try await manager.sampleCurrentSnapshot()
        assert(snapshot2 != nil, "Sampled snapshot must not be nil")
        if let s = snapshot2 {
            assert(s.receivedBytes == 200_000, "Updated receivedBytes must match")
            assert(s.transmittedBytes == 100_000, "Updated transmittedBytes must match")
        }
        count += 1

        // Test 3: Path update to unsatisfied clears snapshot
        mockPathProvider.simulatePathUpdate(.unsatisfied)
        // Allow brief async task processing
        try? await Task.sleep(nanoseconds: 15_000_000)
        let snapshot3 = await manager.currentSnapshot
        assert(snapshot3 == nil, "Snapshot must be nil when path becomes unsatisfied")
        count += 1

        // Test 4: Stop monitoring resets snapshot and state
        await manager.stopMonitoring()
        let isMonAfterStop = await manager.isMonitoring
        assert(!isMonAfterStop, "Manager must not be monitoring after stop")
        let snapshot4 = await manager.currentSnapshot
        assert(snapshot4 == nil, "Snapshot must be nil after stop")
        count += 1

        return count
    }
}
