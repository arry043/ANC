import Foundation

/// Unit test suite for `NetworkInterfaceSelector` interface selection rules.
public enum NetworkInterfaceSelectorTests {
    public static func run() throws -> Int {
        var count = 0
        let selector = NetworkInterfaceSelector()

        let wifiStats = NetworkInterfaceStatistics(
            name: "en0",
            type: .wifi,
            receivedBytes: 50_000,
            transmittedBytes: 25_000,
            isUp: true,
            isRunning: true,
            isLoopback: false,
            isVirtual: false
        )

        let ethStats = NetworkInterfaceStatistics(
            name: "en1",
            type: .ethernet,
            receivedBytes: 100_000,
            transmittedBytes: 50_000,
            isUp: true,
            isRunning: true,
            isLoopback: false,
            isVirtual: false
        )

        let loopbackStats = NetworkInterfaceStatistics(
            name: "lo0",
            type: .other,
            receivedBytes: 10_000,
            transmittedBytes: 10_000,
            isUp: true,
            isRunning: true,
            isLoopback: true,
            isVirtual: false
        )

        let vpnStats = NetworkInterfaceStatistics(
            name: "utun2",
            type: .other,
            receivedBytes: 30_000,
            transmittedBytes: 15_000,
            isUp: true,
            isRunning: true,
            isLoopback: false,
            isVirtual: true
        )

        let downStats = NetworkInterfaceStatistics(
            name: "en2",
            type: .wifi,
            receivedBytes: 0,
            transmittedBytes: 0,
            isUp: false,
            isRunning: false,
            isLoopback: false,
            isVirtual: false
        )

        // Test 1: Direct active interface name match
        let pathWithEn0 = NetworkPathState(
            status: .satisfied,
            availableInterfaceTypes: [.wifi],
            activeInterfaceName: "en0",
            activeInterfaceType: .wifi,
            isExpensive: false,
            isConstrained: false
        )
        let result1 = selector.selectInterface(pathState: pathWithEn0, statistics: [wifiStats, loopbackStats, vpnStats])
        if case .selected(let selected, let reason) = result1 {
            assert(selected.name == "en0", "Must select en0")
            assert(reason == .activePathInterface, "Selection reason must be activePathInterface")
        } else {
            assertionFailure("Expected selected interface for path with activeInterfaceName en0")
        }
        count += 1

        // Test 2: Fallback to active interface type match when name is absent
        let pathWithTypeOnly = NetworkPathState(
            status: .satisfied,
            availableInterfaceTypes: [.wifi],
            activeInterfaceName: nil,
            activeInterfaceType: .wifi,
            isExpensive: false,
            isConstrained: false
        )
        let result2 = selector.selectInterface(pathState: pathWithTypeOnly, statistics: [wifiStats, loopbackStats])
        if case .selected(let selected, let reason) = result2 {
            assert(selected.name == "en0", "Must select en0 via type match")
            assert(reason == .activeInterfaceTypeMatch, "Selection reason must be activeInterfaceTypeMatch")
        } else {
            assertionFailure("Expected selected interface for path with activeInterfaceType .wifi")
        }
        count += 1

        // Test 3: Loopback exclusion
        let result3 = selector.selectInterface(pathState: pathWithEn0, statistics: [loopbackStats])
        if case .noUsableInterfaces = result3 {
            // expected
        } else {
            assertionFailure("Loopback interface must never be selected")
        }
        count += 1

        // Test 4: Down interface exclusion
        let result4 = selector.selectInterface(pathState: NetworkPathState(
            status: .satisfied,
            availableInterfaceTypes: [.wifi],
            activeInterfaceName: "en2",
            activeInterfaceType: .wifi,
            isExpensive: false,
            isConstrained: false
        ), statistics: [downStats])
        if case .noUsableInterfaces = result4 {
            // expected
        } else {
            assertionFailure("Down interface must not be selected")
        }
        count += 1

        // Test 5: Unsatisfied path state yields noActivePath
        let result5 = selector.selectInterface(pathState: .unsatisfied, statistics: [wifiStats, ethStats])
        if case .noActivePath = result5 {
            // expected
        } else {
            assertionFailure("Unsatisfied path must yield noActivePath")
        }
        count += 1

        // Test 6: Zero double counting — tunnel vs physical interface
        // When physical Wi-Fi is active, selector selects physical interface en0, never summing utun2
        let result6 = selector.selectInterface(pathState: pathWithEn0, statistics: [wifiStats, vpnStats])
        if case .selected(let selected, _) = result6 {
            assert(selected.name == "en0", "Must select physical interface en0, not virtual")
            assert(selected.receivedBytes == 50_000, "Must contain only en0 received bytes without summing")
            assert(selected.transmittedBytes == 25_000, "Must contain only en0 transmitted bytes without summing")
        } else {
            assertionFailure("Expected en0 to be selected")
        }
        count += 1

        // Test 7: Deterministic candidate fallback priority (Ethernet over Wi-Fi)
        let ambiguousPath = NetworkPathState(
            status: .satisfied,
            availableInterfaceTypes: [.ethernet, .wifi],
            activeInterfaceName: nil,
            activeInterfaceType: nil,
            isExpensive: false,
            isConstrained: false
        )
        let result7 = selector.selectInterface(pathState: ambiguousPath, statistics: [wifiStats, ethStats])
        if case .selected(let selected, let reason) = result7 {
            assert(selected.name == "en1", "Ethernet en1 must take priority over Wi-Fi en0")
            assert(reason == .primaryUsableFallback, "Selection reason must be primaryUsableFallback")
        } else {
            assertionFailure("Expected deterministic fallback selection")
        }
        count += 1

        return count
    }
}
