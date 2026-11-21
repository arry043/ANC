import Foundation

/// Presentation format options when `DisplayMode.bothDirections` is active.
public enum BothDirectionsStyle: String, Sendable, Equatable, Hashable, CaseIterable, Codable {
    /// Display independent numerical speeds for both download and upload: `↓ 2.45 MB/s ↑ 120 KB/s`.
    case separateSpeeds = "separateSpeeds"

    /// Display both arrows with a single numerical speed representing the dominant direction: `↓ ↑ 2.45 MB/s`.
    case combinedArrows = "combinedArrows"
}
