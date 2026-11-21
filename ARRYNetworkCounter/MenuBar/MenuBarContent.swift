import Foundation

/// Immutable model representing the display-ready content for the menu bar status item.
public struct MenuBarContent: Sendable, Equatable, Hashable {
    /// Active display mode.
    public let displayMode: DisplayMode

    /// Active presentation style when both directions are displayed.
    public let bothDirectionsStyle: BothDirectionsStyle

    /// Current download speed formatted string (e.g. "2.45 MB/s"), or nil if unavailable.
    public let downloadSpeedText: String?

    /// Current upload speed formatted string (e.g. "120 KB/s"), or nil if unavailable.
    public let uploadSpeedText: String?

    /// Active dominant direction determined by `DominantDirectionEngine`.
    public let dominantDirection: NetworkDirection

    /// User-pinned direction used when `displayMode == .singleDirectionManual`.
    public let manualDirection: NetworkDirection

    /// Indicates whether active network connectivity is satisfied.
    public let isConnected: Bool

    /// Creates a new `MenuBarContent` instance.
    public init(
        displayMode: DisplayMode = .bothDirections,
        bothDirectionsStyle: BothDirectionsStyle = .combinedArrows,
        downloadSpeedText: String? = nil,
        uploadSpeedText: String? = nil,
        dominantDirection: NetworkDirection = .download,
        manualDirection: NetworkDirection = .download,
        isConnected: Bool = true
    ) {
        self.displayMode = displayMode
        self.bothDirectionsStyle = bothDirectionsStyle
        self.downloadSpeedText = downloadSpeedText
        self.uploadSpeedText = uploadSpeedText
        self.dominantDirection = dominantDirection
        self.manualDirection = manualDirection
        self.isConnected = isConnected
    }

    /// Convenience default representing idle traffic (`0 KB/s`).
    public static let idle = MenuBarContent(
        displayMode: .bothDirections,
        bothDirectionsStyle: .combinedArrows,
        downloadSpeedText: "0 KB/s",
        uploadSpeedText: "0 KB/s",
        dominantDirection: .download,
        manualDirection: .download,
        isConnected: true
    )

    /// Convenience default representing disconnected network path.
    public static let disconnected = MenuBarContent(
        displayMode: .bothDirections,
        bothDirectionsStyle: .combinedArrows,
        downloadSpeedText: "0 KB/s",
        uploadSpeedText: "0 KB/s",
        dominantDirection: .download,
        manualDirection: .download,
        isConnected: false
    )
}
