import Cocoa

/// Application delegate coordinating the AppKit lifecycle for ARRY Network Counter.
/// Prepares the application for NSStatusItem integration in Phase 08.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Application initialized as a menu bar utility (LSUIElement = true).
        // Actual status item and monitoring will be established in subsequent phases.
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup hooks ready for future monitoring engine teardown.
    }
}
