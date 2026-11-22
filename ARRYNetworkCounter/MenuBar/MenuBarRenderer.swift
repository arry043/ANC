import AppKit

/// Stateless renderer converting `MenuBarContent` models into styled `NSAttributedString` instances for status item buttons.
public enum MenuBarRenderer {
    /// Zero speed fallback string.
    private static let zeroSpeedString = "0 KB/s"

    /// Renders an attributed string representing the current menu bar content with colored arrows and monospaced speed text.
    ///
    /// - Parameter content: Display model describing active speeds, modes, and directions.
    /// - Returns: An immutable `NSAttributedString` styled with `MenuBarAppearance` attributes.
    public static func render(content: MenuBarContent) -> NSAttributedString {
        let result = NSMutableAttributedString()

        let dlText = content.downloadSpeedText ?? zeroSpeedString
        let ulText = content.uploadSpeedText ?? zeroSpeedString

        switch content.displayMode {
        case .bothDirections:
            switch content.bothDirectionsStyle {
            case .combinedArrows:
                // Format: "↓ ↑ <dominantSpeed>"
                appendArrow(MenuBarAppearance.downloadSymbol, color: MenuBarAppearance.downloadColor, to: result)
                appendSpacer(" ", to: result)
                appendArrow(MenuBarAppearance.uploadSymbol, color: MenuBarAppearance.uploadColor, to: result)
                appendSpacer(" ", to: result)

                let dominantSpeed = (content.dominantDirection == .download) ? dlText : ulText
                appendSpeed(dominantSpeed, to: result)

            case .separateSpeeds:
                // Format: "↓ <dlSpeed>    ↑ <ulSpeed>"
                appendArrow(MenuBarAppearance.downloadSymbol, color: MenuBarAppearance.downloadColor, to: result)
                appendSpacer(" ", to: result)
                appendSpeed(dlText, to: result)
                appendSpacer(MenuBarAppearance.separateSpeedsSpacer, to: result)
                appendArrow(MenuBarAppearance.uploadSymbol, color: MenuBarAppearance.uploadColor, to: result)
                appendSpacer(" ", to: result)
                appendSpeed(ulText, to: result)
            }

        case .singleDirectionManual:
            // Format: "↓ <dlSpeed>" or "↑ <ulSpeed>" depending on manual direction preference
            switch content.manualDirection {
            case .download:
                appendArrow(MenuBarAppearance.downloadSymbol, color: MenuBarAppearance.downloadColor, to: result)
                appendSpacer(" ", to: result)
                appendSpeed(dlText, to: result)

            case .upload:
                appendArrow(MenuBarAppearance.uploadSymbol, color: MenuBarAppearance.uploadColor, to: result)
                appendSpacer(" ", to: result)
                appendSpeed(ulText, to: result)
            }

        case .singleDirectionAutomatic:
            // Format: "↓ <dlSpeed>" or "↑ <ulSpeed>" depending on dominant direction
            switch content.dominantDirection {
            case .download:
                appendArrow(MenuBarAppearance.downloadSymbol, color: MenuBarAppearance.downloadColor, to: result)
                appendSpacer(" ", to: result)
                appendSpeed(dlText, to: result)

            case .upload:
                appendArrow(MenuBarAppearance.uploadSymbol, color: MenuBarAppearance.uploadColor, to: result)
                appendSpacer(" ", to: result)
                appendSpeed(ulText, to: result)
            }
        }

        return result
    }

    /// Produces a plain unadorned string representation for accessibility labels and test assertions.
    ///
    /// - Parameter content: Display model describing active speeds, modes, and directions.
    /// - Returns: A standard `String` representation.
    public static func renderPlainText(content: MenuBarContent) -> String {
        render(content: content).string
    }

    // MARK: - Private Attribute Helpers

    private static func appendArrow(_ symbol: String, color: NSColor, to target: NSMutableAttributedString) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MenuBarAppearance.arrowFont,
            .foregroundColor: color
        ]
        target.append(NSAttributedString(string: symbol, attributes: attributes))
    }

    private static func appendSpeed(_ speed: String, to target: NSMutableAttributedString) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MenuBarAppearance.speedFont,
            .foregroundColor: MenuBarAppearance.textColor
        ]
        target.append(NSAttributedString(string: speed, attributes: attributes))
    }

    private static func appendSpacer(_ spacer: String, to target: NSMutableAttributedString) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MenuBarAppearance.speedFont,
            .foregroundColor: MenuBarAppearance.textColor
        ]
        target.append(NSAttributedString(string: spacer, attributes: attributes))
    }
}
