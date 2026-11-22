import Foundation

/// Thread-safe, `UserDefaults`-backed persistent storage provider for application preferences.
///
/// Implements `PreferencesStoring` and guarantees safe defaults, invalid stored value recovery,
/// independent key updates, and support for isolated test suites via dependency injection.
public final class PreferencesStore: PreferencesStoring, @unchecked Sendable {
    /// Configurable preference keys.
    public struct Keys: Sendable, Equatable {
        public let displayMode: String
        public let bothDirectionsStyle: String
        public let manualDirection: String
        public let launchAtLogin: String

        public init(
            displayMode: String = "displayMode",
            bothDirectionsStyle: String = "bothDirectionsStyle",
            manualDirection: String = "manualDirection",
            launchAtLogin: String = "launchAtLogin"
        ) {
            self.displayMode = displayMode
            self.bothDirectionsStyle = bothDirectionsStyle
            self.manualDirection = manualDirection
            self.launchAtLogin = launchAtLogin
        }

        /// Default storage keys per ADR-020 and Phase 10 specifications.
        public static let `default` = Keys()
    }

    private let userDefaults: UserDefaults
    public let keys: Keys
    private let lock = NSLock()

    /// Creates a new `PreferencesStore` instance.
    ///
    /// - Parameters:
    ///   - userDefaults: Backing `UserDefaults` instance (defaults to `.standard`).
    ///   - keys: Storage keys configuration.
    public init(
        userDefaults: UserDefaults = .standard,
        keys: Keys = .default
    ) {
        self.userDefaults = userDefaults
        self.keys = keys
    }

    // MARK: - Display Mode

    /// Retrieves the persisted display mode, falling back to `.bothDirections` if missing or invalid.
    public func getDisplayMode() -> DisplayMode {
        lock.lock()
        defer { lock.unlock() }

        guard let raw = userDefaults.object(forKey: keys.displayMode) else {
            // Check legacy/prefixed key fallback
            if let fallbackRaw = userDefaults.string(forKey: AppConfiguration.PersistenceKeys.displayMode),
               let mode = DisplayMode(rawValue: fallbackRaw) {
                return mode
            }
            return AppPreferences.default.displayMode
        }

        if let str = raw as? String, let mode = DisplayMode(rawValue: str) {
            return mode
        }

        // Invalid stored value: repair in storage and fall back to safe default
        userDefaults.set(AppPreferences.default.displayMode.rawValue, forKey: keys.displayMode)
        return AppPreferences.default.displayMode
    }

    /// Persists the selected display mode without modifying unrelated preferences.
    public func setDisplayMode(_ mode: DisplayMode) {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.set(mode.rawValue, forKey: keys.displayMode)
    }

    // MARK: - Both Directions Style

    /// Retrieves the persisted both-directions style, falling back to `.separateSpeeds` if missing or invalid.
    public func getBothDirectionsStyle() -> BothDirectionsStyle {
        lock.lock()
        defer { lock.unlock() }

        guard let raw = userDefaults.object(forKey: keys.bothDirectionsStyle) else {
            if let fallbackRaw = userDefaults.string(forKey: AppConfiguration.PersistenceKeys.bothDirectionsStyle),
               let style = BothDirectionsStyle(rawValue: fallbackRaw) {
                return style
            }
            return AppPreferences.default.bothDirectionsStyle
        }

        if let str = raw as? String, let style = BothDirectionsStyle(rawValue: str) {
            return style
        }

        // Invalid stored value: repair in storage and fall back to safe default
        userDefaults.set(AppPreferences.default.bothDirectionsStyle.rawValue, forKey: keys.bothDirectionsStyle)
        return AppPreferences.default.bothDirectionsStyle
    }

    /// Persists the selected both-directions style without modifying unrelated preferences.
    public func setBothDirectionsStyle(_ style: BothDirectionsStyle) {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.set(style.rawValue, forKey: keys.bothDirectionsStyle)
    }

    // MARK: - Manual Direction

    /// Retrieves the persisted manual direction, falling back to `.download` if missing or invalid.
    public func getManualDirection() -> NetworkDirection {
        lock.lock()
        defer { lock.unlock() }

        guard let raw = userDefaults.object(forKey: keys.manualDirection) else {
            if let fallbackRaw = userDefaults.string(forKey: AppConfiguration.PersistenceKeys.manualDirection),
               let dir = NetworkDirection(rawValue: fallbackRaw) {
                return dir
            }
            return AppPreferences.default.manualDirection
        }

        if let str = raw as? String, let dir = NetworkDirection(rawValue: str) {
            return dir
        }

        // Invalid stored value: repair in storage and fall back to safe default
        userDefaults.set(AppPreferences.default.manualDirection.rawValue, forKey: keys.manualDirection)
        return AppPreferences.default.manualDirection
    }

    /// Persists the selected manual direction without modifying unrelated preferences.
    public func setManualDirection(_ direction: NetworkDirection) {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.set(direction.rawValue, forKey: keys.manualDirection)
    }

    // MARK: - Launch at Login

    /// Retrieves the persisted launch-at-login preference, falling back to `false` if missing or invalid.
    public func getLaunchAtLogin() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard let raw = userDefaults.object(forKey: keys.launchAtLogin) else {
            if userDefaults.object(forKey: AppConfiguration.PersistenceKeys.launchAtLogin) != nil {
                return userDefaults.bool(forKey: AppConfiguration.PersistenceKeys.launchAtLogin)
            }
            return AppPreferences.default.launchAtLogin
        }

        if let boolVal = raw as? Bool {
            return boolVal
        }
        if let numVal = raw as? NSNumber {
            return numVal.boolValue
        }

        // Invalid stored value: repair in storage and fall back to safe default
        userDefaults.set(AppPreferences.default.launchAtLogin, forKey: keys.launchAtLogin)
        return AppPreferences.default.launchAtLogin
    }

    /// Persists the launch-at-login preference without modifying unrelated preferences.
    public func setLaunchAtLogin(_ enabled: Bool) {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.set(enabled, forKey: keys.launchAtLogin)
    }

    // MARK: - Whole Model Access

    /// Loads the composite `AppPreferences` model from storage.
    public func loadPreferences() -> AppPreferences {
        AppPreferences(
            displayMode: getDisplayMode(),
            bothDirectionsStyle: getBothDirectionsStyle(),
            manualDirection: getManualDirection(),
            launchAtLogin: getLaunchAtLogin()
        )
    }

    /// Persists all values from the provided `AppPreferences` model.
    public func savePreferences(_ preferences: AppPreferences) {
        setDisplayMode(preferences.displayMode)
        setBothDirectionsStyle(preferences.bothDirectionsStyle)
        setManualDirection(preferences.manualDirection)
        setLaunchAtLogin(preferences.launchAtLogin)
    }

    /// Resets all preference keys to approved default values.
    public func resetToDefaults() {
        savePreferences(.default)
    }
}
