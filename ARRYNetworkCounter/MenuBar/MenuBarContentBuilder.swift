import Foundation

/// Central builder responsible for converting coordinator state and preferences into display-ready `MenuBarContent`.
///
/// `MenuBarContentBuilder` encapsulates display mode business rules, selecting which directional arrows and speed
/// values must be presented based on `DisplayMode`, `BothDirectionsStyle`, manual direction pinning, dominant direction,
/// and connection status.
public enum MenuBarContentBuilder {
    /// Zero speed fallback string.
    public static let zeroSpeedString = "0 KB/s"

    /// Builds a `MenuBarContent` instance from application state.
    ///
    /// - Parameters:
    ///   - preferences: Active application preferences.
    ///   - pathState: Current network path status.
    ///   - latestMeasurement: Latest calculated speed measurement, if available.
    ///   - dominantDirection: Current dominant direction calculated by `DominantDirectionEngine`.
    /// - Returns: A display-ready `MenuBarContent` value.
    public static func build(
        preferences: AppPreferences,
        pathState: NetworkPathState,
        latestMeasurement: SpeedMeasurement?,
        dominantDirection: NetworkDirection
    ) -> MenuBarContent {
        let isConnected = (pathState.status == .satisfied)
        let dlText: String
        let ulText: String

        if isConnected, let measurement = latestMeasurement {
            dlText = SpeedFormatter.format(measurement.download)
            ulText = SpeedFormatter.format(measurement.upload)
        } else {
            dlText = zeroSpeedString
            ulText = zeroSpeedString
        }

        return MenuBarContent(
            displayMode: preferences.displayMode,
            bothDirectionsStyle: preferences.bothDirectionsStyle,
            singleDirectionArrowStyle: preferences.singleDirectionArrowStyle,
            downloadSpeedText: dlText,
            uploadSpeedText: ulText,
            dominantDirection: dominantDirection,
            manualDirection: preferences.manualDirection,
            isConnected: isConnected
        )
    }
}
