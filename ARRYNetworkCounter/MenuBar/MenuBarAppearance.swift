import AppKit

/// Defines colors, symbols, and typographic styling for the macOS menu bar status item.
public enum MenuBarAppearance {
    /// Semantic green color for incoming network traffic (Download).
    /// Chosen for high contrast and readability across Light and Dark macOS menu bar appearances.
    public static let downloadColor = NSColor(srgbRed: 0x30 / 255.0, green: 0xB8 / 255.0, blue: 0x6B / 255.0, alpha: 1.0)

    /// Semantic blue color for outgoing network traffic (Upload).
    /// Chosen for clear visual distinction from download in both appearances.
    public static let uploadColor = NSColor(srgbRed: 0x39 / 255.0, green: 0x88 / 255.0, blue: 0xE8 / 255.0, alpha: 1.0)

    /// Standard downward arrow symbol representing download traffic.
    public static let downloadSymbol = "↓"

    /// Standard upward arrow symbol representing upload traffic.
    public static let uploadSymbol = "↑"

    /// Typography for directional indicators (semibold system font).
    public static let arrowFont = NSFont.systemFont(ofSize: 11.5, weight: .semibold)

    /// Typography for numerical speeds (monospaced digits to prevent layout jitter as numbers change).
    public static let speedFont = NSFont.monospacedDigitSystemFont(ofSize: 11.5, weight: .medium)

    /// Dynamic text color adapting to macOS Light Mode, Dark Mode, and menu bar translucency.
    public static var textColor: NSColor {
        NSColor.headerTextColor
    }
}
