import Foundation

/// Defines the contract for managing the application's macOS login-item lifecycle.
@MainActor
public protocol LaunchAtLoginManaging: AnyObject {
    /// Indicates whether launch-at-login is currently configured.
    var isEnabled: Bool { get }

    /// Configures the launch-at-login state.
    ///
    /// - Parameter enabled: `true` to enable launch-at-login, `false` to disable.
    func setEnabled(_ enabled: Bool) async throws
}

/// Service managing launch-at-login preference state and system registration.
@MainActor
public final class LaunchAtLoginService: LaunchAtLoginManaging {
    private let preferencesStore: PreferencesStore
    private let loginItemManager: LoginItemManager?

    /// Creates a new `LaunchAtLoginService` instance.
    ///
    /// - Parameters:
    ///   - preferencesStore: Persistent storage provider.
    ///   - loginItemManager: Optional `LoginItemManager` for system registration.
    public init(
        preferencesStore: PreferencesStore = PreferencesStore(),
        loginItemManager: LoginItemManager? = nil
    ) {
        self.preferencesStore = preferencesStore
        self.loginItemManager = loginItemManager
    }

    /// Reflects the active configuration status.
    public var isEnabled: Bool {
        if let manager = loginItemManager {
            return manager.isEnabled
        }
        return preferencesStore.getLaunchAtLogin()
    }

    /// Sets the launch-at-login state and synchronizes with system registration.
    ///
    /// - Parameter enabled: Desired launch-at-login state.
    public func setEnabled(_ enabled: Bool) async throws {
        if let manager = loginItemManager {
            try await manager.setEnabled(enabled)
        } else {
            preferencesStore.setLaunchAtLogin(enabled)
        }
    }
}
