import AppKit
import SwiftUI
import Combine

/// Central coordinator and presentation manager for the native macOS Settings window.
///
/// Isolated to `@MainActor` to manage the AppKit `NSWindow` lifecycle safely and ensure
/// preference updates propagate immediately to `ApplicationCoordinator` and `MenuBarManager`.
@MainActor
public final class SettingsManager: NSObject, ObservableObject, NSWindowDelegate {
    /// Active user preferences driving the Settings interface and observer updates.
    @Published public private(set) var preferences: AppPreferences

    /// Persistent preferences storage provider.
    public let preferencesStore: PreferencesStore

    /// Associated application coordinator.
    public weak var coordinator: ApplicationCoordinator?

    /// Managed native macOS Settings window.
    public private(set) var window: NSWindow?

    /// Indicates whether the Settings window is currently open and visible.
    public var isWindowOpen: Bool {
        guard let window = window else { return false }
        return window.isVisible
    }

    /// Creates a new `SettingsManager` instance.
    ///
    /// - Parameters:
    ///   - coordinator: Optional injected application coordinator.
    ///   - preferencesStore: Injected persistent storage provider.
    public init(
        coordinator: ApplicationCoordinator? = nil,
        preferencesStore: PreferencesStore = PreferencesStore()
    ) {
        self.coordinator = coordinator
        self.preferencesStore = preferencesStore
        self.preferences = coordinator?.preferences ?? preferencesStore.loadPreferences()
        super.init()
    }

    // MARK: - Window Management

    /// Presents the native Settings window, focusing and bringing to front if already open.
    public func showSettingsWindow() {
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(settingsManager: self)
        let hostingController = NSHostingController(rootView: settingsView)

        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "ARRY Network Counter Settings"
        newWindow.styleMask = [.titled, .closable, .miniaturizable]
        newWindow.isReleasedWhenClosed = false
        newWindow.setContentSize(NSSize(width: 460, height: 520))
        newWindow.minSize = NSSize(width: 430, height: 480)
        newWindow.center()
        newWindow.delegate = self

        self.window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Closes the native Settings window if currently open.
    public func closeSettingsWindow() {
        window?.close()
        window = nil
    }

    // MARK: - NSWindowDelegate

    public func windowWillClose(_ notification: Notification) {
        objectWillChange.send()
    }

    // MARK: - Preference Updates & Immediate Propagation

    /// Updates preferences, persisting them to storage and notifying the application coordinator immediately.
    ///
    /// - Parameter newPreferences: The updated preferences model.
    public func updatePreferences(_ newPreferences: AppPreferences) {
        self.preferences = newPreferences
        preferencesStore.savePreferences(newPreferences)
        coordinator?.applyPreferences(newPreferences)
    }

    /// Updates the active display mode while preserving user configuration for other modes.
    ///
    /// - Parameter mode: The newly selected display mode.
    public func updateDisplayMode(_ mode: DisplayMode) {
        var updated = preferences
        updated.displayMode = mode
        updatePreferences(updated)
    }

    /// Updates the display style for Both Directions mode.
    ///
    /// - Parameter style: The selected both-directions presentation style.
    public func updateBothDirectionsStyle(_ style: BothDirectionsStyle) {
        var updated = preferences
        updated.bothDirectionsStyle = style
        updatePreferences(updated)
    }

    /// Updates the manual direction selection.
    ///
    /// - Parameter direction: The selected network direction.
    public func updateManualDirection(_ direction: NetworkDirection) {
        var updated = preferences
        updated.manualDirection = direction
        updatePreferences(updated)
    }

    /// Updates the launch-at-login preference.
    ///
    /// - Parameter enabled: `true` to enable launch at login, `false` to disable.
    public func updateLaunchAtLogin(_ enabled: Bool) {
        var updated = preferences
        updated.launchAtLogin = enabled
        updatePreferences(updated)
    }
}
