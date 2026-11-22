import AppKit
import SwiftUI

/// End-to-end integration and behavior test suite for `SettingsManager`, `SettingsView`,
/// immediate preference propagation, menu bar re-rendering, and window presentation.
public enum SettingsBehaviorTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        // Create isolated test environment
        let suiteName = "in.arrry.test.settings.\(UUID().uuidString)"
        guard let suite = UserDefaults(suiteName: suiteName) else {
            fatalError("Failed to create isolated UserDefaults suite")
        }
        suite.removePersistentDomain(forName: suiteName)

        let store = PreferencesStore(userDefaults: suite)
        let mockMonitor = MockNetworkMonitor()
        let mockLoginProvider = MockLoginItemProvider(initialStatus: .notRegistered)
        let loginItemManager = LoginItemManager(
            provider: mockLoginProvider,
            preferencesStore: store
        )
        let coordinator = ApplicationCoordinator(
            preferencesStore: store,
            networkMonitor: mockMonitor
        )
        let menuBarManager = MenuBarManager(coordinator: coordinator)
        let settingsManager = SettingsManager(
            coordinator: coordinator,
            preferencesStore: store,
            loginItemManager: loginItemManager
        )

        // Connect menu bar settings action callback to settings manager
        menuBarManager.onOpenSettings = { [weak settingsManager] in
            settingsManager?.showSettingsWindow()
        }

        // Start coordinator and menu bar
        menuBarManager.start()
        await coordinator.start()

        guard let initialStatusItem = menuBarManager.statusItem else {
            assertionFailure("Status item must be created after start()")
            return count
        }

        let wifi = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)

        // Establish active path and baseline snapshot
        await mockMonitor.simulatePathUpdate(.satisfiedWiFi)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let snap0 = NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap0)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Snapshot 1: DL = 500 KB/s, UL = 250 KB/s (Download dominant)
        let snap1 = NetworkSnapshot(
            receivedBytes: 10_500_000,
            transmittedBytes: 5_250_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap1)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // ---------------------------------------------------------------------
        // Test 1: Initial state reflection from store to SettingsManager
        // ---------------------------------------------------------------------
        assert(settingsManager.preferences == .default, "SettingsManager must initialize with default preferences")
        assert(coordinator.preferences == .default, "Coordinator preferences must equal default")
        let initialTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(initialTitle == "↓ 500 KB/s    ↑ 250 KB/s", "Initial render must be Separate Speeds, got '\(initialTitle)'")
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Both Directions Style change propagates immediately to MenuBar
        // ---------------------------------------------------------------------
        settingsManager.updateBothDirectionsStyle(.combinedArrows)
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(settingsManager.preferences.bothDirectionsStyle == .combinedArrows, "SettingsManager style must update")
        assert(coordinator.preferences.bothDirectionsStyle == .combinedArrows, "Coordinator style must update")
        assert(store.getBothDirectionsStyle() == .combinedArrows, "Persisted style must be combinedArrows")

        let combinedTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(combinedTitle == "↓ ↑ 500 KB/s", "Menu bar must immediately render '↓ ↑ 500 KB/s', got '\(combinedTitle)'")
        assert(menuBarManager.statusItem === initialStatusItem, "Status item must NOT be recreated on style change")
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Switching to Single Direction — Manual Download
        // ---------------------------------------------------------------------
        settingsManager.updateDisplayMode(.singleDirectionManual)
        settingsManager.updateManualDirection(.download)
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(settingsManager.preferences.displayMode == .singleDirectionManual, "SettingsManager mode must be manual")
        assert(settingsManager.preferences.manualDirection == .download, "SettingsManager direction must be download")
        let manualDLTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(manualDLTitle == "↓ 500 KB/s", "Manual download must immediately render '↓ 500 KB/s', got '\(manualDLTitle)'")
        assert(menuBarManager.statusItem === initialStatusItem, "Status item must NOT be recreated on mode change")
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Switching to Single Direction — Manual Upload
        // ---------------------------------------------------------------------
        settingsManager.updateManualDirection(.upload)
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(settingsManager.preferences.manualDirection == .upload, "Direction must be upload")
        let manualULTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(manualULTitle == "↑ 250 KB/s", "Manual upload must immediately render '↑ 250 KB/s', got '\(manualULTitle)'")
        assert(store.getManualDirection() == .upload, "Persisted manualDirection must be upload")
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Manual direction is NOT overridden by automatic dominance changes
        // ---------------------------------------------------------------------
        // Introduce massive download spike (DL: 5,000 KB/s, UL: 10 KB/s)
        let snap2 = NetworkSnapshot(
            receivedBytes: 15_500_000,
            transmittedBytes: 5_260_000,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap2)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let persistentManualTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(persistentManualTitle == "↑ 10 KB/s", "Manual upload mode must NOT be overridden by download traffic dominance")
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: Switching to Single Direction — Automatic
        // ---------------------------------------------------------------------
        settingsManager.updateDisplayMode(.singleDirectionAutomatic)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // In snap2, DL traffic was 5,000 KB/s -> download dominant
        let autoTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(autoTitle == "↓ 5 MB/s", "Automatic mode must reflect dominant download speed, got '\(autoTitle)'")
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: Preserving inactive mode preferences when switching
        // ---------------------------------------------------------------------
        // Verify current state before switching back:
        // bothDirectionsStyle was set to .combinedArrows earlier.
        // manualDirection was set to .upload earlier.
        assert(settingsManager.preferences.bothDirectionsStyle == .combinedArrows, "bothDirectionsStyle must be preserved")
        assert(settingsManager.preferences.manualDirection == .upload, "manualDirection must be preserved")

        // Switch back to bothDirections
        settingsManager.updateDisplayMode(.bothDirections)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(settingsManager.preferences.bothDirectionsStyle == .combinedArrows, "Restored bothDirections must keep .combinedArrows")
        let restoredBothTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(restoredBothTitle == "↓ ↑ 5 MB/s", "Restored mode must immediately render combined arrows, got '\(restoredBothTitle)'")

        // Switch back to manual mode
        settingsManager.updateDisplayMode(.singleDirectionManual)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(settingsManager.preferences.manualDirection == .upload, "Restored manual mode must keep .upload")
        let restoredManualTitle = menuBarManager.statusItem?.button?.attributedTitle.string ?? ""
        assert(restoredManualTitle == "↑ 10 KB/s", "Restored manual mode must immediately render upload speed")
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: Launch at login preference and placeholder service
        // ---------------------------------------------------------------------
        let loginService = LaunchAtLoginService(
            preferencesStore: store,
            loginItemManager: loginItemManager
        )
        assert(loginService.isEnabled == false, "Initial launchAtLogin service must be false")

        await settingsManager.updateLaunchAtLogin(true)
        assert(settingsManager.preferences.launchAtLogin == true, "SettingsManager launchAtLogin must be true")
        assert(store.getLaunchAtLogin() == true, "Persisted launchAtLogin must be true")
        assert(loginService.isEnabled == true, "LaunchAtLoginService must reflect true")

        try await loginService.setEnabled(false)
        assert(store.getLaunchAtLogin() == false, "Service setEnabled(false) must update store")
        count += 1

        // ---------------------------------------------------------------------
        // Test 9: Window presentation and duplicate window prevention
        // ---------------------------------------------------------------------
        assert(!settingsManager.isWindowOpen, "Settings window must not be open initially")

        settingsManager.showSettingsWindow()
        assert(settingsManager.isWindowOpen, "Settings window must be open after showSettingsWindow()")
        guard let window1 = settingsManager.window else {
            assertionFailure("Window must exist after showSettingsWindow()")
            return count
        }
        assert(window1.title == "ARRY Network Counter Settings", "Window title must be 'ARRY Network Counter Settings'")

        // Second call must focus existing window without recreating
        settingsManager.showSettingsWindow()
        assert(settingsManager.window === window1, "Second showSettingsWindow() call must NOT create a duplicate window")
        assert(settingsManager.isWindowOpen, "Window must remain open")

        // Close window
        settingsManager.closeSettingsWindow()
        assert(!settingsManager.isWindowOpen, "Settings window must be closed after closeSettingsWindow()")
        count += 1

        // ---------------------------------------------------------------------
        // Test 10: Menu bar manager settings action triggers window presentation
        // ---------------------------------------------------------------------
        assert(!settingsManager.isWindowOpen, "Window should be closed before menu action")
        menuBarManager.handleSettingsAction()
        assert(settingsManager.isWindowOpen, "handleSettingsAction must trigger settings presentation")
        settingsManager.closeSettingsWindow()
        count += 1

        // Cleanup
        menuBarManager.stop()
        await coordinator.stop()
        suite.removePersistentDomain(forName: suiteName)

        return count
    }
}
