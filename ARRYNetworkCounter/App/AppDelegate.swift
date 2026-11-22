import Cocoa

/// Application delegate coordinating the AppKit lifecycle for ARRY Network Counter.
/// Manages the native menu bar status item and application-level lifecycle events.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Central application coordinator managing preferences and service lifecycle.
    public let coordinator: ApplicationCoordinator

    /// Menu bar manager responsible for the NSStatusItem lifecycle and dynamic rendering.
    public private(set) var menuBarManager: MenuBarManager?

    /// Settings manager responsible for native Settings window lifecycle and preference coordination.
    public private(set) var settingsManager: SettingsManager?

    /// Login item manager responsible for macOS startup registration.
    public private(set) var loginItemManager: LoginItemManager?

    public override init() {
        self.coordinator = ApplicationCoordinator()
        super.init()
    }

    public init(coordinator: ApplicationCoordinator) {
        self.coordinator = coordinator
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let loginItem = LoginItemManager()
        self.loginItemManager = loginItem

        let settings = SettingsManager(coordinator: coordinator, loginItemManager: loginItem)
        self.settingsManager = settings

        let manager = MenuBarManager(coordinator: coordinator)
        manager.onOpenSettings = { [weak settings] in
            settings?.showSettingsWindow()
        }
        self.menuBarManager = manager
        manager.start()

        Task {
            await coordinator.start()
        }
    }

    @objc public func showSettingsWindow(_ sender: Any?) {
        settingsManager?.showSettingsWindow()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        settingsManager?.closeSettingsWindow()
        menuBarManager?.stop()

        if coordinator.isRunning {
            Task {
                await coordinator.stop()
                NSApp.reply(toApplicationShouldTerminate: true)
            }
            return .terminateLater
        } else {
            return .terminateNow
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        settingsManager?.closeSettingsWindow()
        settingsManager = nil

        menuBarManager?.stop()
        menuBarManager = nil
    }
}
