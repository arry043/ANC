import Foundation

/// Represents a network interface identified by the operating system.
///
/// `NetworkInterface` provides a strongly typed representation of system interfaces,
/// distinguishing between Wi-Fi, Ethernet, cellular, loopback, and virtual interfaces.
public struct NetworkInterface: Sendable, Equatable, Hashable, Identifiable, Codable {
    /// The system BSD name of the interface (e.g., "en0", "en1", "lo0").
    public let name: String

    /// The BSD interface index assigned by the kernel, if available.
    public let index: UInt32?

    /// The broad hardware or logical category of the interface.
    public let type: InterfaceType

    /// Indicates whether the interface is suitable for measuring user-facing network traffic.
    public let isUsable: Bool

    /// Interface identifier conforming to `Identifiable`.
    public var id: String {
        name
    }

    /// Indicates whether this interface is a loopback interface (`lo0`, etc.).
    public var isLoopback: Bool {
        type == .loopback
    }

    /// Creates a new `NetworkInterface`.
    ///
    /// - Parameters:
    ///   - name: The system name of the interface.
    ///   - index: Optional system interface index.
    ///   - type: The interface type category.
    ///   - isUsable: Flag indicating if the interface carries active routable traffic.
    public init(
        name: String,
        index: UInt32? = nil,
        type: InterfaceType = .other,
        isUsable: Bool = true
    ) {
        self.name = name
        self.index = index
        self.type = type
        self.isUsable = isUsable
    }

    /// Classification of macOS network interfaces.
    public enum InterfaceType: String, Sendable, Equatable, Hashable, Codable, CaseIterable {
        case wifi
        case ethernet
        case cellular
        case loopback
        case virtual
        case other
    }
}
