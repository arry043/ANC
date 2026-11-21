import Foundation

/// Approved primary menu bar display modes for ARRY Network Counter.
///
/// Configures how network traffic information is presented in the macOS menu bar.
public enum DisplayMode: String, Sendable, Equatable, Hashable, CaseIterable, Codable {
    /// Both directions are tracked; presentation format is determined by `BothDirectionsStyle`.
    case bothDirections = "bothDirections"

    /// Only a single user-selected direction (Download or Upload) is displayed continuously.
    case singleDirectionManual = "singleDirectionManual"

    /// Automatically displays the direction currently carrying dominant traffic.
    case singleDirectionAutomatic = "singleDirectionAutomatic"
}
