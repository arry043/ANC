import Foundation
#if canImport(ServiceManagement)
import ServiceManagement
#endif

/// Application login item status representation mirroring `SMAppService.Status`.
public enum LoginItemStatus: String, Sendable, Equatable, Hashable {
    case notRegistered = "notRegistered"
    case enabled = "enabled"
    case requiresApproval = "requiresApproval"
    case notFound = "notFound"
}

/// Abstract contract for interacting with system login-item registration.
public protocol LoginItemProviding: Sendable {
    /// The current login-item registration status reported by the system.
    var status: LoginItemStatus { get }

    /// Requests system registration of the application as a login item.
    func register() throws

    /// Requests system unregistration of the application as a login item.
    func unregister() throws

    /// Opens macOS System Settings directly to the Login Items pane.
    func openSystemSettingsLoginItems()
}

#if canImport(ServiceManagement)
/// Production provider backed by Apple's `SMAppService.mainApp` on macOS 13.0+.
public final class SystemLoginItemProvider: LoginItemProviding, @unchecked Sendable {
    public init() {}

    public var status: LoginItemStatus {
        let appService = SMAppService.mainApp
        switch appService.status {
        case .enabled:
            return .enabled
        case .notRegistered:
            return .notRegistered
        case .requiresApproval:
            return .requiresApproval
        case .notFound:
            return .notFound
        @unknown default:
            return .notRegistered
        }
    }

    public func register() throws {
        try SMAppService.mainApp.register()
    }

    public func unregister() throws {
        try SMAppService.mainApp.unregister()
    }

    public func openSystemSettingsLoginItems() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
#endif

/// Thread-safe mock provider for unit testing login-item registration scenarios without touching user system settings.
public final class MockLoginItemProvider: LoginItemProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var simulatedStatus: LoginItemStatus
    public private(set) var registerCount = 0
    public private(set) var unregisterCount = 0
    public private(set) var openSettingsCount = 0
    public var shouldThrowOnRegister: (any Error)? = nil
    public var shouldThrowOnUnregister: (any Error)? = nil

    public init(initialStatus: LoginItemStatus = .notRegistered) {
        self.simulatedStatus = initialStatus
    }

    public var status: LoginItemStatus {
        lock.lock()
        defer { lock.unlock() }
        return simulatedStatus
    }

    public func setSimulatedStatus(_ newStatus: LoginItemStatus) {
        lock.lock()
        defer { lock.unlock() }
        simulatedStatus = newStatus
    }

    public func register() throws {
        lock.lock()
        defer { lock.unlock() }
        registerCount += 1
        if let err = shouldThrowOnRegister {
            throw err
        }
        simulatedStatus = .enabled
    }

    public func unregister() throws {
        lock.lock()
        defer { lock.unlock() }
        unregisterCount += 1
        if let err = shouldThrowOnUnregister {
            throw err
        }
        simulatedStatus = .notRegistered
    }

    public func openSystemSettingsLoginItems() {
        lock.lock()
        defer { lock.unlock() }
        openSettingsCount += 1
    }
}

/// Central manager overseeing macOS login-item lifecycle and Settings state synchronization.
///
/// Isolated to `@MainActor` to coordinate published UI state safely and interface with `PreferencesStore`.
@MainActor
public final class LoginItemManager: ObservableObject, LaunchAtLoginManaging {
    /// Current authoritative system login-item registration status.
    @Published public private(set) var status: LoginItemStatus

    /// User-facing error or guidance message from the latest registration operation.
    @Published public private(set) var lastErrorMessage: String?

    /// Indicates whether an asynchronous registration operation is actively in progress.
    @Published public private(set) var isProcessing: Bool = false

    /// Indicates whether the login item is currently registered and enabled in macOS.
    public var isEnabled: Bool {
        status == .enabled
    }

    private let provider: any LoginItemProviding
    private let preferencesStore: PreferencesStore

    /// Creates a new `LoginItemManager`.
    ///
    /// - Parameters:
    ///   - provider: Underlying `LoginItemProviding` abstraction (defaults to `SystemLoginItemProvider`).
    ///   - preferencesStore: Preferences storage provider.
    public init(
        provider: (any LoginItemProviding)? = nil,
        preferencesStore: PreferencesStore = PreferencesStore()
    ) {
        #if canImport(ServiceManagement)
        let defaultProvider = provider ?? SystemLoginItemProvider()
        #else
        let defaultProvider = provider ?? MockLoginItemProvider()
        #endif
        self.provider = defaultProvider
        self.preferencesStore = preferencesStore
        let initialStatus = defaultProvider.status
        self.status = initialStatus
        preferencesStore.setLaunchAtLogin(initialStatus == .enabled)
    }

    /// Re-queries the authoritative registration status from macOS and synchronizes preferences.
    public func refreshStatus() {
        let current = provider.status
        self.status = current
        preferencesStore.setLaunchAtLogin(current == .enabled)
    }

    /// Enables or disables the application's login launch configuration.
    ///
    /// - Parameter enabled: `true` to register for launch at login, `false` to unregister.
    public func setEnabled(_ enabled: Bool) async throws {
        isProcessing = true
        defer { isProcessing = false }
        lastErrorMessage = nil

        do {
            let currentStatus = provider.status
            if enabled {
                if currentStatus != .enabled {
                    try provider.register()
                }
            } else {
                if currentStatus != .notRegistered {
                    try provider.unregister()
                }
            }

            let updatedStatus = provider.status
            self.status = updatedStatus
            preferencesStore.setLaunchAtLogin(updatedStatus == .enabled)

            if updatedStatus == .requiresApproval {
                lastErrorMessage = "macOS requires user approval in System Settings."
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            refreshStatus()
            throw error
        }
    }

    /// Directs the user to macOS System Settings > Login Items pane using supported Apple APIs.
    public func openSystemSettings() {
        provider.openSystemSettingsLoginItems()
    }
}
