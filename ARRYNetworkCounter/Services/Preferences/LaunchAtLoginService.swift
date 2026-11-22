import Foundation

/// Defines the contract for managing the application's macOS login-item lifecycle.
///
/// Phase 10 implements preference model persistence and provides this boundary contract.
/// Full system service registration with `ServiceManagement` and `SMAppService` will be
/// finalized in Phase 11 (Application Lifecycle & Launch at Login).
public protocol LaunchAtLoginManaging: Sendable {
    /// Indicates whether launch-at-login is currently configured.
    var isEnabled: Bool { get }

    /// Configures the launch-at-login state.
    ///
    /// - Parameter enabled: `true` to enable launch-at-login, `false` to disable.
    func setEnabled(_ enabled: Bool) async throws
}

/// Service managing the launch-at-login preference state for Phase 10.
///
/// Delegates persistence to `PreferencesStore`. Actual macOS `SMAppService` login-item
/// registration is formally scoped to Phase 11.
public final class LaunchAtLoginService: LaunchAtLoginManaging, @unchecked Sendable {
    private let preferencesStore: PreferencesStore

    /// Creates a new `LaunchAtLoginService` instance.
    ///
    /// - Parameter preferencesStore: Persistent storage provider.
    public init(preferencesStore: PreferencesStore = PreferencesStore()) {
        self.preferencesStore = preferencesStore
    }

    /// Reflects the currently persisted preference.
    public var isEnabled: Bool {
        preferencesStore.getLaunchAtLogin()
    }

    /// Sets the launch-at-login preference.
    ///
    /// - Parameter enabled: Desired launch-at-login state.
    public func setEnabled(_ enabled: Bool) async throws {
        preferencesStore.setLaunchAtLogin(enabled)
        // Formal macOS SMAppService registration will be finalized in Phase 11.
    }
}
