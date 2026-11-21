import Foundation

/// Immutable model representing native link-layer statistics and counters for a network interface.
///
/// Encapsulates cumulative received and transmitted byte counters extracted from BSD `struct if_data`
/// along with interface identity, operational flags, and categorization.
public struct NetworkInterfaceStatistics: Sendable, Equatable, Hashable, Identifiable {
    /// BSD interface name (e.g., "en0", "en1", "lo0", "utun0").
    public let name: String

    /// Kernel interface index from `sockaddr_dl.sdl_index`, if available.
    public let index: UInt32?

    /// Hardware or logical interface classification category.
    public let type: NetworkInterface.InterfaceType

    /// Cumulative total bytes received on this interface (`ifi_ibytes`).
    public let receivedBytes: UInt64

    /// Cumulative total bytes transmitted on this interface (`ifi_obytes`).
    public let transmittedBytes: UInt64

    /// BSD operational flag indicating whether the interface is up (`IFF_UP`).
    public let isUp: Bool

    /// BSD operational flag indicating whether the interface is running (`IFF_RUNNING`).
    public let isRunning: Bool

    /// BSD flag indicating whether the interface is a loopback device (`IFF_LOOPBACK`).
    public let isLoopback: Bool

    /// Indicates whether the interface represents a virtual, bridge, or tunnel interface.
    public let isVirtual: Bool

    /// Wall-clock timestamp when this statistics sample was read.
    public let timestamp: Date

    /// Monotonic timestamp in nanoseconds for jitter-free elapsed time calculation.
    public let monotonicTimeNanoseconds: UInt64

    /// Stable identifier conforming to `Identifiable`.
    public var id: String {
        name
    }

    /// Indicates whether the interface is administratively and operationally active for routable traffic.
    public var isUsable: Bool {
        isUp && isRunning && !isLoopback
    }

    /// Creates a new `NetworkInterfaceStatistics` instance.
    public init(
        name: String,
        index: UInt32? = nil,
        type: NetworkInterface.InterfaceType = .other,
        receivedBytes: UInt64 = 0,
        transmittedBytes: UInt64 = 0,
        isUp: Bool = true,
        isRunning: Bool = true,
        isLoopback: Bool = false,
        isVirtual: Bool = false,
        timestamp: Date = Date(),
        monotonicTimeNanoseconds: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) {
        self.name = name
        self.index = index
        self.type = type
        self.receivedBytes = receivedBytes
        self.transmittedBytes = transmittedBytes
        self.isUp = isUp
        self.isRunning = isRunning
        self.isLoopback = isLoopback
        self.isVirtual = isVirtual
        self.timestamp = timestamp
        self.monotonicTimeNanoseconds = monotonicTimeNanoseconds
    }

    /// Converts this statistics record into an immutable `NetworkInterface` model.
    public func toNetworkInterface() -> NetworkInterface {
        NetworkInterface(
            name: name,
            index: index,
            type: type,
            isUsable: isUsable
        )
    }
}
