import Foundation
#if canImport(Network)
import Network
#endif

/// Strongly typed application-level representation of macOS network path connectivity and interface state.
///
/// `NetworkPathState` is an immutable, concurrency-safe value type that decouples application logic
/// from Apple's `Network.framework` `NWPath` object.
public struct NetworkPathState: Sendable, Equatable, Hashable, Codable {
    /// The current path connectivity status.
    public let status: ConnectivityStatus

    /// List of all network interfaces currently reported as available by the path.
    public let availableInterfaces: [NetworkInterface]

    /// Unique collection of interface types available on the active path.
    public let availableInterfaceTypes: [NetworkInterface.InterfaceType]

    /// System name of the primary active interface (e.g., "en0"), if determined.
    public let activeInterfaceName: String?

    /// Category of the primary active interface, if determined.
    public let activeInterfaceType: NetworkInterface.InterfaceType?

    /// Indicates whether the network path is considered expensive (e.g., cellular data or Personal Hotspot).
    public let isExpensive: Bool

    /// Indicates whether the network path is operating under low data mode / constrained conditions.
    public let isConstrained: Bool

    /// Indicates whether the network path is satisfied and capable of transferring data.
    public var isConnected: Bool {
        status == .satisfied
    }

    /// Indicates whether a Wi-Fi interface is available on the current network path.
    public var hasWiFi: Bool {
        availableInterfaceTypes.contains(.wifi)
    }

    /// Indicates whether a wired Ethernet interface is available on the current network path.
    public var hasEthernet: Bool {
        availableInterfaceTypes.contains(.ethernet)
    }

    /// Indicates whether a cellular interface is available on the current network path.
    public var hasCellular: Bool {
        availableInterfaceTypes.contains(.cellular)
    }

    /// Creates a new `NetworkPathState`.
    public init(
        status: ConnectivityStatus,
        availableInterfaces: [NetworkInterface] = [],
        availableInterfaceTypes: [NetworkInterface.InterfaceType] = [],
        activeInterfaceName: String? = nil,
        activeInterfaceType: NetworkInterface.InterfaceType? = nil,
        isExpensive: Bool = false,
        isConstrained: Bool = false
    ) {
        self.status = status
        self.availableInterfaces = availableInterfaces
        self.availableInterfaceTypes = availableInterfaceTypes
        self.activeInterfaceName = activeInterfaceName
        self.activeInterfaceType = activeInterfaceType
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
    }

    /// Standard unsatisfied state indicating no routable network connectivity.
    public static let unsatisfied = NetworkPathState(
        status: .unsatisfied,
        availableInterfaces: [],
        availableInterfaceTypes: [],
        activeInterfaceName: nil,
        activeInterfaceType: nil,
        isExpensive: false,
        isConstrained: false
    )

    /// State indicating connection setup is required.
    public static let requiresConnection = NetworkPathState(
        status: .requiresConnection,
        availableInterfaces: [],
        availableInterfaceTypes: [],
        activeInterfaceName: nil,
        activeInterfaceType: nil,
        isExpensive: false,
        isConstrained: false
    )

    /// Standard satisfied Wi-Fi state for testing and initialization.
    public static let satisfiedWiFi = NetworkPathState(
        status: .satisfied,
        availableInterfaces: [
            NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)
        ],
        availableInterfaceTypes: [.wifi],
        activeInterfaceName: "en0",
        activeInterfaceType: .wifi,
        isExpensive: false,
        isConstrained: false
    )

    /// Standard satisfied Ethernet state for testing and initialization.
    public static let satisfiedEthernet = NetworkPathState(
        status: .satisfied,
        availableInterfaces: [
            NetworkInterface(name: "en1", index: 2, type: .ethernet, isUsable: true)
        ],
        availableInterfaceTypes: [.ethernet],
        activeInterfaceName: "en1",
        activeInterfaceType: .ethernet,
        isExpensive: false,
        isConstrained: false
    )

    /// Connectivity status categories matching `NWPath.Status`.
    public enum ConnectivityStatus: String, Sendable, Equatable, Hashable, Codable, CaseIterable {
        case satisfied
        case unsatisfied
        case requiresConnection
    }
}

#if canImport(Network)
extension NetworkPathState {
    /// Creates a `NetworkPathState` by translating an Apple `NWPath` instance.
    public init(nwPath: NWPath) {
        let status: ConnectivityStatus
        switch nwPath.status {
        case .satisfied:
            status = .satisfied
        case .unsatisfied:
            status = .unsatisfied
        case .requiresConnection:
            status = .requiresConnection
        @unknown default:
            status = .unsatisfied
        }

        var interfaces: [NetworkInterface] = []
        var types: Set<NetworkInterface.InterfaceType> = []

        for iface in nwPath.availableInterfaces {
            let mappedType: NetworkInterface.InterfaceType
            switch iface.type {
            case .wifi:
                mappedType = .wifi
            case .wiredEthernet:
                mappedType = .ethernet
            case .cellular:
                mappedType = .cellular
            case .loopback:
                mappedType = .loopback
            case .other:
                mappedType = .other
            @unknown default:
                mappedType = .other
            }

            types.insert(mappedType)
            interfaces.append(
                NetworkInterface(
                    name: iface.name,
                    index: UInt32(iface.index),
                    type: mappedType,
                    isUsable: mappedType != .loopback
                )
            )
        }

        let primaryInterface = interfaces.first(where: { $0.isUsable })

        self.init(
            status: status,
            availableInterfaces: interfaces,
            availableInterfaceTypes: Array(types),
            activeInterfaceName: primaryInterface?.name,
            activeInterfaceType: primaryInterface?.type,
            isExpensive: nwPath.isExpensive,
            isConstrained: nwPath.isConstrained
        )
    }
}
#endif
