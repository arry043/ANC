import Foundation

/// Unit test suite for `NetworkPathState`.
public enum NetworkPathStateTests {
    public static func run() throws -> Int {
        var count = 0
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test 1: Unsatisfied state
        let unsatisfied = NetworkPathState.unsatisfied
        assert(!unsatisfied.isConnected, "Unsatisfied state must report isConnected == false")
        assert(unsatisfied.status == .unsatisfied, "Status must be unsatisfied")
        assert(unsatisfied.availableInterfaces.isEmpty, "Unsatisfied state interfaces must be empty")
        assert(!unsatisfied.hasWiFi, "Unsatisfied state must not have WiFi")
        assert(!unsatisfied.hasEthernet, "Unsatisfied state must not have Ethernet")
        assert(!unsatisfied.hasCellular, "Unsatisfied state must not have Cellular")
        count += 1

        // Test 2: Requires Connection state
        let requiresConn = NetworkPathState.requiresConnection
        assert(requiresConn.status == .requiresConnection, "Status must be requiresConnection")
        assert(!requiresConn.isConnected, "requiresConnection must not be connected")
        count += 1

        // Test 3: Satisfied Wi-Fi state
        let wifiState = NetworkPathState.satisfiedWiFi
        assert(wifiState.isConnected, "Satisfied state must report isConnected == true")
        assert(wifiState.hasWiFi, "satisfiedWiFi must report hasWiFi == true")
        assert(!wifiState.hasEthernet, "satisfiedWiFi must not report Ethernet")
        assert(wifiState.activeInterfaceName == "en0", "Active interface must be en0")
        assert(wifiState.activeInterfaceType == .wifi, "Active interface type must be wifi")
        count += 1

        // Test 4: Satisfied Ethernet state
        let ethState = NetworkPathState.satisfiedEthernet
        assert(ethState.isConnected, "Satisfied Ethernet must be connected")
        assert(ethState.hasEthernet, "Must report hasEthernet == true")
        assert(!ethState.hasWiFi, "Must not report hasWiFi")
        assert(ethState.activeInterfaceName == "en1", "Active interface must be en1")
        assert(ethState.activeInterfaceType == .ethernet, "Active interface type must be ethernet")
        count += 1

        // Test 5: Expensive and constrained flags
        let cellular = NetworkPathState(
            status: .satisfied,
            availableInterfaces: [
                NetworkInterface(name: "pdp_ip0", index: 3, type: .cellular, isUsable: true)
            ],
            availableInterfaceTypes: [.cellular],
            activeInterfaceName: "pdp_ip0",
            activeInterfaceType: .cellular,
            isExpensive: true,
            isConstrained: true
        )
        assert(cellular.hasCellular, "Must report hasCellular == true")
        assert(cellular.isExpensive, "Cellular path must report isExpensive == true")
        assert(cellular.isConstrained, "Cellular path must report isConstrained == true")
        count += 1

        // Test 6: Equality and hashing
        let stateA = NetworkPathState.satisfiedWiFi
        let stateB = NetworkPathState.satisfiedWiFi
        let stateC = NetworkPathState.satisfiedEthernet
        assert(stateA == stateB, "Identical states must be equal")
        assert(stateA != stateC, "Different states must not be equal")
        assert(stateA.hashValue == stateB.hashValue, "Equal states must have identical hash values")
        count += 1

        // Test 7: Codable round-trip
        let encodedData = try encoder.encode(cellular)
        let decoded = try decoder.decode(NetworkPathState.self, from: encodedData)
        assert(decoded == cellular, "Decoded state must equal original state")
        assert(decoded.isExpensive == true, "Decoded isExpensive must be preserved")
        assert(decoded.isConstrained == true, "Decoded isConstrained must be preserved")
        count += 1

        return count
    }
}
