import Foundation

/// Application preferences model representing all persisted user choices.
///
/// Conforms to `Codable` and `Sendable`, supporting persistent storage via `UserDefaults`.
public struct AppPreferences: Sendable, Equatable, Hashable, Codable {
    /// Selected menu bar display mode.
    public var displayMode: DisplayMode

    /// Presentation style when `displayMode` is `.bothDirections`.
    public var bothDirectionsStyle: BothDirectionsStyle

    /// Selected direction when `displayMode` is `.singleDirectionManual`.
    public var manualDirection: NetworkDirection

    /// Whether the application is configured to launch automatically at macOS login.
    public var launchAtLogin: Bool

    /// Creates a new `AppPreferences` instance with explicit values.
    public init(
        displayMode: DisplayMode = .bothDirections,
        bothDirectionsStyle: BothDirectionsStyle = .separateSpeeds,
        manualDirection: NetworkDirection = .download,
        launchAtLogin: Bool = false
    ) {
        self.displayMode = displayMode
        self.bothDirectionsStyle = bothDirectionsStyle
        self.manualDirection = manualDirection
        self.launchAtLogin = launchAtLogin
    }

    /// Approved default application preferences according to project specifications and ADR-022.
    public static let `default` = AppPreferences(
        displayMode: .bothDirections,
        bothDirectionsStyle: .separateSpeeds,
        manualDirection: .download,
        launchAtLogin: false
    )
}
