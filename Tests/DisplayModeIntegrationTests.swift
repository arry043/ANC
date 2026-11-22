import AppKit

/// End-to-end integration test suite verifying dynamic display mode transitions, visual output,
/// status item stability, uninterrupted monitoring, and preference persistence.
public enum DisplayModeIntegrationTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        let mockStore = MockPreferencesStore(initialPreferences: .default)
        let mockMonitor = MockNetworkMonitor()
        let coordinator = ApplicationCoordinator(
            preferencesStore: mockStore,
            networkMonitor: mockMonitor
        )
        let manager = MenuBarManager(coordinator: coordinator)

        // Start coordinator and menu bar manager
        manager.start()
        await coordinator.start()

        guard let initialStatusItem = manager.statusItem else {
            assertionFailure("Status item must be created after start()")
            return count
        }

        let wifi = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)

        // Establish active path
        await mockMonitor.simulatePathUpdate(.satisfiedWiFi)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Baseline snapshot
        let snap0 = NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap0)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Snapshot 1: 1s later -> DL: 500,000 B/s (500 KB/s), UL: 250,000 B/s (250 KB/s)
        let snap1 = NetworkSnapshot(
            receivedBytes: 10_500_000,
            transmittedBytes: 5_250_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap1)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // ---------------------------------------------------------------------
        // Test 1: Mode 1 - Both Directions: Separate Speeds
        // ---------------------------------------------------------------------
        let separatePrefs = AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .download,
            launchAtLogin: false
        )
        try await coordinator.updatePreferences(separatePrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let title1 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title1 == "↓ 500 KB/s    ↑ 250 KB/s", "Separate speeds must render '↓ 500 KB/s    ↑ 250 KB/s', got '\(title1)'")

        // Verify arrow colors in attributed string
        if let attr = manager.statusItem?.button?.attributedTitle {
            let str = attr.string as NSString
            let downRange = str.range(of: "↓")
            let upRange = str.range(of: "↑")
            let downColor = attr.attribute(.foregroundColor, at: downRange.location, effectiveRange: nil) as? NSColor
            let upColor = attr.attribute(.foregroundColor, at: upRange.location, effectiveRange: nil) as? NSColor
            assert(downColor == MenuBarAppearance.downloadColor, "Download arrow must be downloadColor (#30B86B)")
            assert(upColor == MenuBarAppearance.uploadColor, "Upload arrow must be uploadColor (#3988E8)")
        }
        count += 1

        // Independent update: DL changes to 800 KB/s, UL stays 250 KB/s
        let snap2 = NetworkSnapshot(
            receivedBytes: 11_300_000,
            transmittedBytes: 5_500_000,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap2)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let title2 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title2 == "↓ 800 KB/s    ↑ 250 KB/s", "Separate speeds must update independently, got '\(title2)'")
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Mode 1 - Both Directions: Combined Arrows with Dominant Speed
        // ---------------------------------------------------------------------
        let combinedPrefs = AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        try await coordinator.updatePreferences(combinedPrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let title3 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title3 == "↓ ↑ 800 KB/s", "Combined arrows with dominant DL must render '↓ ↑ 800 KB/s', got '\(title3)'")

        // Heavy upload burst: sample 1 (hysteresis candidate: upload)
        let snap3 = NetworkSnapshot(
            receivedBytes: 11_310_000, // delta DL: 10 KB/s
            transmittedBytes: 7_500_000, // delta UL: 2,000 KB/s (2 MB/s)
            monotonicTimeNanoseconds: 4_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap3)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let title4 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title4 == "↓ ↑ 10 KB/s", "First upload sample does not switch dominant direction yet (DL still active), got '\(title4)'")

        // Heavy upload burst: sample 2 (confirms switch to upload dominant!)
        let snap4 = NetworkSnapshot(
            receivedBytes: 11_320_000, // delta DL: 10 KB/s
            transmittedBytes: 9_500_000, // delta UL: 2,000 KB/s (2 MB/s)
            monotonicTimeNanoseconds: 5_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap4)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let title5 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title5 == "↓ ↑ 2 MB/s", "Second upload sample switches dominant direction to upload, got '\(title5)'")
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Mode 2 - Single Direction: Manual Download (Ignores Upload Dominance)
        // ---------------------------------------------------------------------
        let manualDLPrefs = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        try await coordinator.updatePreferences(manualDLPrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let title6 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title6 == "↓ 10 KB/s", "Manual download must strictly show download speed even when upload dominates, got '\(title6)'")
        assert(!title6.contains("↑"), "Manual download must not contain upload arrow")
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Mode 2 - Single Direction: Manual Upload (Ignores Download Dominance)
        // ---------------------------------------------------------------------
        // Switch traffic back to heavy download
        let snap5 = NetworkSnapshot(
            receivedBytes: 21_320_000, // delta DL: 10,000 KB/s (10 MB/s)
            transmittedBytes: 9_550_000, // delta UL: 50 KB/s
            monotonicTimeNanoseconds: 6_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap5)

        let manualULPrefs = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: false
        )
        try await coordinator.updatePreferences(manualULPrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let title7 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title7 == "↑ 50 KB/s", "Manual upload must strictly show upload speed even when download dominates, got '\(title7)'")
        assert(!title7.contains("↓"), "Manual upload must not contain download arrow")
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Mode 3 - Single Direction: Automatic
        // ---------------------------------------------------------------------
        let autoPrefs = AppPreferences(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        try await coordinator.updatePreferences(autoPrefs)

        // Snapshot 6 confirms DL dominance (sample 2 of 10 MB/s DL)
        let snap6 = NetworkSnapshot(
            receivedBytes: 31_320_000, // delta DL: 10 MB/s
            transmittedBytes: 9_600_000, // delta UL: 50 KB/s
            monotonicTimeNanoseconds: 7_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap6)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let title8 = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(title8 == "↓ 10 MB/s", "Single direction automatic must show download arrow and speed when download dominates, got '\(title8)'")
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: Network Disconnection Across Modes
        // ---------------------------------------------------------------------
        await mockMonitor.simulatePathUpdate(.unsatisfied)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let discTitleAuto = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(discTitleAuto == "↓ 0 KB/s", "Disconnected automatic mode must show '↓ 0 KB/s', got '\(discTitleAuto)'")

        try await coordinator.updatePreferences(separatePrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let discTitleSep = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(discTitleSep == "↓ 0 KB/s    ↑ 0 KB/s", "Disconnected separate speeds must show '↓ 0 KB/s    ↑ 0 KB/s', got '\(discTitleSep)'")

        try await coordinator.updatePreferences(combinedPrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)
        let discTitleComb = manager.statusItem?.button?.attributedTitle.string ?? ""
        assert(discTitleComb == "↓ ↑ 0 KB/s", "Disconnected combined arrows must show '↓ ↑ 0 KB/s', got '\(discTitleComb)'")
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: Architecture Stability - Status item not recreated, monitoring uninterrupted
        // ---------------------------------------------------------------------
        let currentStatusItem = manager.statusItem
        assert(currentStatusItem === initialStatusItem, "NSStatusItem must never be recreated during display mode transitions")
        let startCount = await mockMonitor.startCount
        assert(startCount == 1, "Monitoring must never be restarted during preference changes")
        assert(coordinator.isRunning, "Coordinator must remain running throughout all transitions")
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: Rapid Preference Updates
        // ---------------------------------------------------------------------
        try await coordinator.updatePreferences(manualDLPrefs)
        try await coordinator.updatePreferences(manualULPrefs)
        try await coordinator.updatePreferences(separatePrefs)
        try await coordinator.updatePreferences(combinedPrefs)
        try await coordinator.updatePreferences(autoPrefs)
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(coordinator.preferences == autoPrefs, "Final preference must prevail")
        assert(manager.statusItem === initialStatusItem, "Status item remains stable under rapid preference updates")
        count += 1

        // ---------------------------------------------------------------------
        // Test 9: Preference Persistence and Restoration
        // ---------------------------------------------------------------------
        let savedPrefs = await mockStore.storedPreferences
        assert(savedPrefs == autoPrefs, "Preferences store must reflect latest saved preferences")

        let restoredCoordinator = ApplicationCoordinator(preferencesStore: mockStore, networkMonitor: nil)
        await restoredCoordinator.start()
        assert(restoredCoordinator.preferences == autoPrefs, "New coordinator must restore saved preferences from store")
        await restoredCoordinator.stop()
        count += 1

        // Cleanup
        manager.stop()
        await coordinator.stop()

        return count
    }
}
