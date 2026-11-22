import Foundation

/// Arrow visibility presentation preference for single-direction display modes.
public enum SingleDirectionArrowStyle: String, Sendable, Equatable, Hashable, CaseIterable, Codable {
    /// Displays directional arrow glyph before the speed value (e.g. `↓ 2.45 MB/s` or `↑ 120 KB/s`).
    case withArrow = "withArrow"

    /// Displays speed value only without arrow glyph (e.g. `2.45 MB/s` or `120 KB/s`).
    case withoutArrows = "withoutArrows"
}
