import Cocoa

/// Application delegate coordinating the AppKit lifecycle for ARRY Network Counter.
/// Prepares the application for NSStatusItem integration in Phase 08.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Central application coordinator managing preferences and service lifecycle.
    public let coordinator: ApplicationCoordinator

    public override init() {
        self.coordinator = ApplicationCoordinator()
        super.init()
    }

    public init(coordinator: ApplicationCoordinator) {
        self.coordinator = coordinator
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            await coordinator.start()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task {
            await coordinator.stop()
        }
    }
}
