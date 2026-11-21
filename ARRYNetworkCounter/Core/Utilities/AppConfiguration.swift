import Foundation

/// Centralized shared application configuration constants for ARRY Network Counter.
public enum AppConfiguration {
    /// User-facing application product name.
    public static let appName = "ARRY Network Counter"

    /// Internal identifier / short abbreviation.
    public static let shortName = "ANC"

    /// Organization name.
    public static let organization = "ARRRY"

    /// Application bundle identifier.
    public static let bundleIdentifier = "in.arrry.networkcounter"

    /// Minimum supported macOS version.
    public static let minimumOSVersion = "macOS 13.0"

    /// Standard target sampling and UI refresh interval in seconds.
    public static let defaultSamplingIntervalSeconds: Double = 1.0

    /// Default idle speed value (0 B/s).
    public static let idleSpeed = NetworkSpeed.zero

    /// Persistence keys used for local storage in `UserDefaults`.
    public enum PersistenceKeys {
        public static let preferences = "in.arrry.networkcounter.preferences"
        public static let displayMode = "in.arrry.networkcounter.displayMode"
        public static let bothDirectionsStyle = "in.arrry.networkcounter.bothDirectionsStyle"
        public static let manualDirection = "in.arrry.networkcounter.manualDirection"
        public static let launchAtLogin = "in.arrry.networkcounter.launchAtLogin"
    }

    /// Application version and build metadata.
    public enum Version {
        public static let versionString = "1.0.0"
        public static let buildNumber = "1"
        public static let copyright = "Copyright © 2026 ARRRY. All rights reserved."
    }
}
