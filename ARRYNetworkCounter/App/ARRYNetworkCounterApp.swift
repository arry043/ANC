import SwiftUI
import AppKit

/// Application entry point for ARRY Network Counter (ANC).
/// Configured for native SwiftUI lifecycle while delegating lifecycle and menu bar integration to AppKit.
@main
struct ARRYNetworkCounterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar utility runs primarily via NSStatusItem in AppDelegate.
        // A Settings scene is prepared here for Phase 10 implementation.
        Settings {
            EmptyView()
        }
    }
}
