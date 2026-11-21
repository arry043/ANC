import Foundation
import Darwin

/// Protocol defining interface statistics retrieval for dependency injection and testing.
public protocol NetworkInterfaceProviding: Sendable {
    /// Enumerates system network interfaces and returns their latest statistics and byte counters.
    func currentInterfaceStatistics() async throws -> [NetworkInterfaceStatistics]
}

/// Errors that may occur during interface statistics enumeration.
public enum NetworkInterfaceProviderError: Error, Equatable, Sendable {
    /// The underlying `getifaddrs()` call failed with the specified POSIX errno.
    case enumerationFailed(errno: Int32)
    /// No network interface records were returned by the operating system.
    case noInterfacesFound
}

/// Production implementation of `NetworkInterfaceProviding` using macOS BSD `getifaddrs()`.
public final class SystemNetworkInterfaceProvider: NetworkInterfaceProviding, Sendable {
    public init() {}

    public func currentInterfaceStatistics() async throws -> [NetworkInterfaceStatistics] {
        try Self.readSystemInterfaceStatistics()
    }

    /// Reads native BSD network interface statistics via `getifaddrs()`.
    ///
    /// Guarantees that `freeifaddrs()` executes on every allocation path.
    public static func readSystemInterfaceStatistics() throws -> [NetworkInterfaceStatistics] {
        var ifap: UnsafeMutablePointer<ifaddrs>? = nil
        let status = getifaddrs(&ifap)
        guard status == 0, let first = ifap else {
            let err = errno
            throw NetworkInterfaceProviderError.enumerationFailed(errno: err)
        }
        defer {
            freeifaddrs(first)
        }

        var results: [NetworkInterfaceStatistics] = []
        var ptr: UnsafeMutablePointer<ifaddrs>? = first
        let now = Date()
        let monotonicNow = DispatchTime.now().uptimeNanoseconds

        while let current = ptr {
            defer { ptr = current.pointee.ifa_next }

            guard let namePtr = current.pointee.ifa_name else {
                continue
            }
            let name = String(cString: namePtr)

            // Validate that ifa_addr exists and sa_family is AF_LINK
            guard let addrPtr = current.pointee.ifa_addr,
                  addrPtr.pointee.sa_family == UInt8(AF_LINK) else {
                continue
            }

            // Extract kernel interface index from sockaddr_dl safely
            let dl = addrPtr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { $0.pointee }
            let index = dl.sdl_index > 0 ? UInt32(dl.sdl_index) : nil

            let flags = current.pointee.ifa_flags
            let isUp = (flags & UInt32(IFF_UP)) != 0
            let isRunning = (flags & UInt32(IFF_RUNNING)) != 0
            let isLoopback = (flags & UInt32(IFF_LOOPBACK)) != 0

            let isVirtual = isVirtualInterface(name: name)
            let type = classifyInterface(name: name, isLoopback: isLoopback, isVirtual: isVirtual)

            // Extract cumulative bytes received and transmitted from struct if_data
            var ibytes: UInt64 = 0
            var obytes: UInt64 = 0
            if let dataPtr = current.pointee.ifa_data {
                let ifData = dataPtr.assumingMemoryBound(to: if_data.self).pointee
                ibytes = UInt64(ifData.ifi_ibytes)
                obytes = UInt64(ifData.ifi_obytes)
            }

            let stat = NetworkInterfaceStatistics(
                name: name,
                index: index,
                type: type,
                receivedBytes: ibytes,
                transmittedBytes: obytes,
                isUp: isUp,
                isRunning: isRunning,
                isLoopback: isLoopback,
                isVirtual: isVirtual,
                timestamp: now,
                monotonicTimeNanoseconds: monotonicNow
            )
            results.append(stat)
        }

        return results
    }

    /// Determines whether an interface name represents a virtual or tunnel device.
    public static func isVirtualInterface(name: String) -> Bool {
        name.hasPrefix("utun") ||
        name.hasPrefix("ipsec") ||
        name.hasPrefix("ppp") ||
        name.hasPrefix("bridge") ||
        name.hasPrefix("awdl") ||
        name.hasPrefix("llw") ||
        name.hasPrefix("anpi") ||
        name.hasPrefix("gif") ||
        name.hasPrefix("stf") ||
        name.hasPrefix("pktap")
    }

    /// Classifies the interface based on name and system characteristics.
    public static func classifyInterface(
        name: String,
        isLoopback: Bool,
        isVirtual: Bool
    ) -> NetworkInterface.InterfaceType {
        if isLoopback || name.hasPrefix("lo") {
            return .loopback
        }
        if name.hasPrefix("pdp_ip") {
            return .cellular
        }
        if isVirtual {
            return .virtual
        }
        if name.hasPrefix("en") {
            // Standard macOS physical / wireless network interfaces
            return .wifi
        }
        return .other
    }
}

/// Thread-safe actor-based mock provider for deterministic unit testing of interface statistics.
public actor MockNetworkInterfaceProvider: NetworkInterfaceProviding {
    private var stubbedStatistics: [NetworkInterfaceStatistics] = []
    private var shouldFailWithError: NetworkInterfaceProviderError? = nil
    public private(set) var callCount = 0

    public init(statistics: [NetworkInterfaceStatistics] = []) {
        self.stubbedStatistics = statistics
    }

    public func setStatistics(_ statistics: [NetworkInterfaceStatistics]) {
        self.stubbedStatistics = statistics
    }

    public func setError(_ error: NetworkInterfaceProviderError?) {
        self.shouldFailWithError = error
    }

    public func currentInterfaceStatistics() async throws -> [NetworkInterfaceStatistics] {
        callCount += 1
        if let err = shouldFailWithError {
            throw err
        }
        return stubbedStatistics
    }
}
