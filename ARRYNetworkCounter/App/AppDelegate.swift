import Cocoa

/// Application delegate coordinating the AppKit lifecycle for ARRY Network Counter.
/// Manages the native menu bar status item and application-level lifecycle events.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Central application coordinator managing preferences and service lifecycle.
    public let coordinator: ApplicationCoordinator

    /// Menu bar manager responsible for the NSStatusItem lifecycle and dynamic rendering.
    public private(set) var menuBarManager: MenuBarManager?

    public override init() {
        self.coordinator = ApplicationCoordinator()
        super.init()
    }

    public init(coordinator: ApplicationCoordinator) {
        self.coordinator = coordinator
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarManager = MenuBarManager(coordinator: coordinator)
        menuBarManager?.start()

        Task {
            await coordinator.start()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        menuBarManager?.stop()
        menuBarManager = nil

        Task {
            await coordinator.stop()
        }
    }
}
