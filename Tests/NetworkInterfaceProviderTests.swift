import Foundation

/// Unit test suite for `SystemNetworkInterfaceProvider` and `MockNetworkInterfaceProvider`.
public enum NetworkInterfaceProviderTests {
    public static func run() async throws -> Int {
        var count = 0

        // Test 1: SystemNetworkInterfaceProvider live retrieval
        let systemProvider = SystemNetworkInterfaceProvider()
        let stats = try await systemProvider.currentInterfaceStatistics()
        assert(!stats.isEmpty, "System provider must return at least one network interface")
        count += 1

        // Test 2: Statistics sanity checks
        for stat in stats {
            assert(!stat.name.isEmpty, "Interface name must not be empty")
            if let idx = stat.index {
                assert(idx >= 0, "Interface index must be non-negative")
            }
            assert(stat.monotonicTimeNanoseconds > 0, "Monotonic time must be greater than zero")
        }
        count += 1

        // Test 3: System provider contains a loopback interface
        let hasLoopback = stats.contains { $0.isLoopback }
        assert(hasLoopback, "System provider must enumerate loopback interface (lo0)")
        count += 1

        // Test 4: Conversion to domain NetworkInterface model
        if let first = stats.first {
            let domainModel = first.toNetworkInterface()
            assert(domainModel.name == first.name, "Domain model name must match statistics name")
            assert(domainModel.index == first.index, "Domain model index must match statistics index")
            assert(domainModel.type == first.type, "Domain model type must match statistics type")
            assert(domainModel.isUsable == first.isUsable, "Domain model isUsable must match statistics isUsable")
            assert(domainModel.isLoopback == first.isLoopback, "Domain model isLoopback must match statistics isLoopback")
        }
        count += 1

        // Test 5: MockNetworkInterfaceProvider retrieval & updates
        let mockProvider = MockNetworkInterfaceProvider(statistics: [
            NetworkInterfaceStatistics(
                name: "en0",
                type: .wifi,
                receivedBytes: 1_000_000,
                transmittedBytes: 500_000,
                isUp: true,
                isRunning: true,
                isLoopback: false,
                isVirtual: false
            )
        ])
        let mockStats = try await mockProvider.currentInterfaceStatistics()
        assert(mockStats.count == 1, "Mock provider must return configured statistics count")
        assert(mockStats[0].name == "en0", "Mock provider must return configured interface name")
        assert(mockStats[0].receivedBytes == 1_000_000, "Received bytes must match mock value")
        count += 1

        // Test 6: Mock provider update
        await mockProvider.setStatistics([
            NetworkInterfaceStatistics(
                name: "en0",
                type: .wifi,
                receivedBytes: 2_000_000,
                transmittedBytes: 1_000_000,
                isUp: true,
                isRunning: true,
                isLoopback: false,
                isVirtual: false
            )
        ])
        let updatedMockStats = try await mockProvider.currentInterfaceStatistics()
        assert(updatedMockStats[0].receivedBytes == 2_000_000, "Mock provider must reflect updated statistics")
        count += 1

        // Test 7: Mock provider error handling
        await mockProvider.setError(.enumerationFailed(errno: 1))
        do {
            _ = try await mockProvider.currentInterfaceStatistics()
            assertionFailure("Mock provider must throw when error is configured")
        } catch let err as NetworkInterfaceProviderError {
            assert(err == .enumerationFailed(errno: 1), "Thrown error must match configured error")
        }
        count += 1

        return count
    }
}
