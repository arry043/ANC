import Foundation

/// Immutable model representing the display-ready content for the menu bar status item.
public struct MenuBarContent: Sendable, Equatable, Hashable {
    /// Active display mode.
    public let displayMode: DisplayMode

    /// Active presentation style when both directions are displayed.
    public let bothDirectionsStyle: BothDirectionsStyle

    /// Active arrow visibility style when a single direction mode is displayed.
    public let singleDirectionArrowStyle: SingleDirectionArrowStyle

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
        singleDirectionArrowStyle: SingleDirectionArrowStyle = .withArrow,
        downloadSpeedText: String? = nil,
        uploadSpeedText: String? = nil,
        dominantDirection: NetworkDirection = .download,
        manualDirection: NetworkDirection = .download,
        isConnected: Bool = true
    ) {
        self.displayMode = displayMode
        self.bothDirectionsStyle = bothDirectionsStyle
        self.singleDirectionArrowStyle = singleDirectionArrowStyle
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
        singleDirectionArrowStyle: .withArrow,
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
        singleDirectionArrowStyle: .withArrow,
        downloadSpeedText: "0 KB/s",
        uploadSpeedText: "0 KB/s",
        dominantDirection: .download,
        manualDirection: .download,
        isConnected: false
    )

    /// Single displayed speed text for modes that render one speed value (nil for separate speeds mode).
    public var singleDisplayedSpeedText: String? {
        switch displayMode {
        case .bothDirections:
            switch bothDirectionsStyle {
            case .combinedArrows:
                return (dominantDirection == .download) ? downloadSpeedText : uploadSpeedText
            case .separateSpeeds, .withoutArrows:
                return nil
            }
        case .singleDirectionManual:
            return (manualDirection == .download) ? downloadSpeedText : uploadSpeedText
        case .singleDirectionAutomatic:
            return (dominantDirection == .download) ? downloadSpeedText : uploadSpeedText
        }
    }

    /// Indicates whether the content reflects zero or non-positive throughput across all displayed directions.
    public var isIdle: Bool {
        (downloadSpeedText == nil || downloadSpeedText == "0 KB/s") &&
        (uploadSpeedText == nil || uploadSpeedText == "0 KB/s")
    }
}
