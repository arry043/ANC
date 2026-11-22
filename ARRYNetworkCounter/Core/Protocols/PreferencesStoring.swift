import Foundation

/// Defines the contract for persisting and retrieving application user preferences.
public protocol PreferencesStoring: Sendable {
    /// Loads the stored user preferences, or returns default preferences if none exist.
    func loadPreferences() async -> AppPreferences

    /// Persists updated user preferences to local storage.
    ///
    /// - Parameter preferences: The updated preferences model to save.
    func savePreferences(_ preferences: AppPreferences) async throws
}

/// An in-memory implementation of `PreferencesStoring` suitable for testing and previewing.
public actor InMemoryPreferencesStore: PreferencesStoring {
    private var preferences: AppPreferences

    public init(initialPreferences: AppPreferences = .default) {
        self.preferences = initialPreferences
    }

    public func loadPreferences() async -> AppPreferences {
        preferences
    }

    public func savePreferences(_ preferences: AppPreferences) async throws {
        self.preferences = preferences
    }
}

/// Standard `UserDefaults` backed implementation of `PreferencesStoring`.
public typealias UserDefaultsPreferencesStore = PreferencesStore

