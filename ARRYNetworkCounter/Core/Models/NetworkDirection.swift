import Foundation

/// Direction of network traffic (incoming or outgoing).
public enum NetworkDirection: String, Sendable, Equatable, Hashable, CaseIterable, Codable {
    /// Incoming network traffic (Download).
    case download = "download"

    /// Outgoing network traffic (Upload).
    case upload = "upload"

    /// Returns the opposite network direction.
    public var opposite: NetworkDirection {
        switch self {
        case .download: return .upload
        case .upload: return .download
        }
    }
}
