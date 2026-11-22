import Foundation
import OSLog

/// Centralized, privacy-conscious logging infrastructure utilizing Apple's Unified Logging System (`OSLog`).
///
/// Log categories separate concerns and avoid emitting sensitive network payloads or per-packet noise.
public enum AppLogger {
    /// Subsystem identifier matching the application bundle identifier.
    public static let subsystem = AppConfiguration.bundleIdentifier

    /// Logger for application startup, shutdown, and lifecycle events.
    public static let lifecycle = Logger(subsystem: subsystem, category: "Lifecycle")

    /// Logger for network path monitoring, interface enumeration, and connectivity recovery.
    public static let network = Logger(subsystem: subsystem, category: "Network")

    /// Logger for settings and user preference persistence events.
    public static let settings = Logger(subsystem: subsystem, category: "Settings")

    /// Logger for menu bar rendering and status item presentation.
    public static let menuBar = Logger(subsystem: subsystem, category: "MenuBar")
}
