import Foundation

/// Unit test suite for `NetworkInterface`.
public enum NetworkInterfaceTests {
    public static func run() throws -> Int {
        var count = 0

        // Test 1: Wi-Fi interface initialization
        let wifi = NetworkInterface(name: "en0", index: 6, type: .wifi, isUsable: true)
        assert(wifi.name == "en0", "Interface name must match")
        assert(wifi.index == 6, "Interface index must match")
        assert(wifi.type == .wifi, "Interface type must be wifi")
        assert(wifi.isUsable, "Wi-Fi interface should be usable")
        assert(!wifi.isLoopback, "Wi-Fi interface must not be loopback")
        assert(wifi.id == "en0", "Identifiable id must match name")
        count += 1

        // Test 2: Loopback interface identification
        let loopback = NetworkInterface(name: "lo0", index: 1, type: .loopback, isUsable: false)
        assert(loopback.isLoopback, "Loopback interface must report isLoopback == true")
        assert(!loopback.isUsable, "Loopback interface should not be marked usable for monitoring")
        count += 1

        // Test 3: Interface equality
        let wifiA = NetworkInterface(name: "en0", index: 6, type: .wifi, isUsable: true)
        let wifiB = NetworkInterface(name: "en0", index: 6, type: .wifi, isUsable: true)
        let eth = NetworkInterface(name: "en1", index: 7, type: .ethernet, isUsable: true)
        assert(wifiA == wifiB, "Equal interfaces must match")
        assert(wifiA != eth, "Different interfaces must not match")
        count += 1

        // Test 4: Codable round-trip
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let encodedData = try encoder.encode(wifi)
        let decoded = try decoder.decode(NetworkInterface.self, from: encodedData)
        assert(decoded == wifi, "Decoded interface must equal encoded interface")
        count += 1

        return count
    }
}
