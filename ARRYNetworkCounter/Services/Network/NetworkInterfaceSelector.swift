import Foundation

/// Selector responsible for matching active network path state to the appropriate interface statistics.
///
/// Enforces single-interface selection policy: never sums overlapping interfaces, excludes loopback,
/// and handles physical, virtual, and VPN tunnel relationships deterministically.
public struct NetworkInterfaceSelector: Sendable {
    public init() {}

    /// Result of an interface selection operation.
    public enum SelectionResult: Sendable, Equatable {
        /// An active interface was successfully selected with its associated statistics.
        case selected(NetworkInterfaceStatistics, reason: SelectionReason)
        /// The network path is not satisfied or disconnected.
        case noActivePath
        /// The requested active interface was not found in the current statistics list.
        case noMatchingInterface(requestedName: String?)
        /// No operational non-loopback interfaces are currently usable.
        case noUsableInterfaces
        /// Statistics retrieval or interface enumeration failed.
        case enumerationFailed(message: String)

        /// The selected interface statistics, if any.
        public var selectedStatistics: NetworkInterfaceStatistics? {
            switch self {
            case .selected(let stats, _):
                return stats
            default:
                return nil
            }
        }

        /// Indicates whether an interface was successfully selected.
        public var isSelected: Bool {
            selectedStatistics != nil
        }
    }

    /// Rationale for selecting a specific interface.
    public enum SelectionReason: String, Sendable, Equatable, Codable {
        /// Matched the explicit primary active interface name reported by the network path.
        case activePathInterface
        /// Matched the primary active interface type reported by the network path.
        case activeInterfaceTypeMatch
        /// Fallback to the primary usable physical network interface.
        case primaryUsableFallback
    }

    /// Evaluates interface statistics against the current network path state.
    ///
    /// - Parameters:
    ///   - pathState: The latest path state from network monitoring.
    ///   - statistics: The latest list of system interface statistics.
    /// - Returns: An explicit `SelectionResult`.
    public func selectInterface(
        pathState: NetworkPathState,
        statistics: [NetworkInterfaceStatistics]
    ) -> SelectionResult {
        // 1. Verify path is satisfied
        guard pathState.status == .satisfied else {
            return .noActivePath
        }

        // 2. Filter out loopback and non-running interfaces
        let usable = statistics.filter { !$0.isLoopback && $0.isUsable }
        guard !usable.isEmpty else {
            return .noUsableInterfaces
        }

        // 3. Prefer exact match by activeInterfaceName from NetworkPathState
        if let activeName = pathState.activeInterfaceName,
           let match = usable.first(where: { $0.name == activeName }) {
            return .selected(match, reason: .activePathInterface)
        }

        // 4. Match by active interface type if active name was unavailable or not found
        if let activeType = pathState.activeInterfaceType {
            // Check if any interface in pathState.availableInterfaces matches
            let matchingNames = pathState.availableInterfaces
                .filter { $0.type == activeType }
                .map { $0.name }

            if let typeMatch = usable.first(where: { matchingNames.contains($0.name) }) {
                return .selected(typeMatch, reason: .activeInterfaceTypeMatch)
            }

            if let fallbackTypeMatch = usable.first(where: { $0.type == activeType }) {
                return .selected(fallbackTypeMatch, reason: .activeInterfaceTypeMatch)
            }
        }

        // 5. Fallback: Prioritize physical interfaces by type (Ethernet > Wi-Fi > Cellular > Other) and name
        let prioritizedUsable = usable.sorted { lhs, rhs in
            let pLhs = Self.interfacePriority(lhs)
            let pRhs = Self.interfacePriority(rhs)
            if pLhs != pRhs {
                return pLhs < pRhs
            }
            return lhs.name < rhs.name
        }

        if let primaryPhysical = prioritizedUsable.first(where: { !$0.isVirtual }) {
            return .selected(primaryPhysical, reason: .primaryUsableFallback)
        }

        // 6. Last resort: select first usable interface
        if let firstUsable = prioritizedUsable.first {
            return .selected(firstUsable, reason: .primaryUsableFallback)
        }

        return .noMatchingInterface(requestedName: pathState.activeInterfaceName)
    }

    private static func interfacePriority(_ stat: NetworkInterfaceStatistics) -> Int {
        if stat.isVirtual { return 100 }
        switch stat.type {
        case .ethernet: return 10
        case .wifi: return 20
        case .cellular: return 30
        case .other: return 40
        case .loopback: return 999
        case .virtual: return 100
        }
    }
}
