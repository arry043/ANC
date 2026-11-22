import Foundation

/// Unit test suite for `PreferencesStore` persistence, defaults, and error recovery.
public enum PreferencesStoreTests {
    public static func run() async throws -> Int {
        var count = 0

        // Helper to produce clean isolated UserDefaults suites
        func makeIsolatedStore() -> (PreferencesStore, UserDefaults, String) {
            let suiteName = "in.arrry.test.prefs.\(UUID().uuidString)"
            guard let suite = UserDefaults(suiteName: suiteName) else {
                fatalError("Failed to create isolated UserDefaults suite")
            }
            suite.removePersistentDomain(forName: suiteName)
            let store = PreferencesStore(userDefaults: suite)
            return (store, suite, suiteName)
        }

        // ---------------------------------------------------------------------
        // Test 1: Default preferences from fresh store
        // ---------------------------------------------------------------------
        let (store1, suite1, name1) = makeIsolatedStore()
        let loaded1 = store1.loadPreferences()
        assert(loaded1.displayMode == .bothDirections, "Default displayMode must be .bothDirections")
        assert(loaded1.bothDirectionsStyle == .separateSpeeds, "Default bothDirectionsStyle must be .separateSpeeds")
        assert(loaded1.manualDirection == .download, "Default manualDirection must be .download")
        assert(loaded1.launchAtLogin == false, "Default launchAtLogin must be false")
        assert(store1.getDisplayMode() == .bothDirections, "getDisplayMode() must return .bothDirections")
        assert(store1.getBothDirectionsStyle() == .separateSpeeds, "getBothDirectionsStyle() must return .separateSpeeds")
        assert(store1.getManualDirection() == .download, "getManualDirection() must return .download")
        assert(store1.getLaunchAtLogin() == false, "getLaunchAtLogin() must return false")
        suite1.removePersistentDomain(forName: name1)
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Saving and loading each preference individually
        // ---------------------------------------------------------------------
        let (store2, suite2, name2) = makeIsolatedStore()
        store2.setDisplayMode(.singleDirectionManual)
        assert(store2.getDisplayMode() == .singleDirectionManual, "Display mode must update to .singleDirectionManual")

        store2.setBothDirectionsStyle(.combinedArrows)
        assert(store2.getBothDirectionsStyle() == .combinedArrows, "Style must update to .combinedArrows")

        store2.setManualDirection(.upload)
        assert(store2.getManualDirection() == .upload, "Direction must update to .upload")

        store2.setLaunchAtLogin(true)
        assert(store2.getLaunchAtLogin() == true, "Launch at login must update to true")

        let composite2 = store2.loadPreferences()
        assert(composite2.displayMode == .singleDirectionManual, "Composite displayMode must match")
        assert(composite2.bothDirectionsStyle == .combinedArrows, "Composite bothDirectionsStyle must match")
        assert(composite2.manualDirection == .upload, "Composite manualDirection must match")
        assert(composite2.launchAtLogin == true, "Composite launchAtLogin must match")
        suite2.removePersistentDomain(forName: name2)
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Relaunch simulation across new store instances on same suite
        // ---------------------------------------------------------------------
        let suiteName3 = "in.arrry.test.prefs.\(UUID().uuidString)"
        guard let suite3 = UserDefaults(suiteName: suiteName3) else {
            fatalError("Failed to create suite")
        }
        let store3A = PreferencesStore(userDefaults: suite3)
        let targetPrefs = AppPreferences(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: true
        )
        store3A.savePreferences(targetPrefs)

        // Simulate application relaunch with fresh instance
        let store3B = PreferencesStore(userDefaults: suite3)
        let reloaded3 = store3B.loadPreferences()
        assert(reloaded3 == targetPrefs, "Preferences must be faithfully restored across store instances")
        assert(reloaded3.displayMode == .singleDirectionAutomatic, "Restored displayMode must match")
        assert(reloaded3.bothDirectionsStyle == .combinedArrows, "Restored bothDirectionsStyle must match")
        assert(reloaded3.manualDirection == .upload, "Restored manualDirection must match")
        assert(reloaded3.launchAtLogin == true, "Restored launchAtLogin must match")
        suite3.removePersistentDomain(forName: suiteName3)
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Missing keys fallback to safe defaults without crashing
        // ---------------------------------------------------------------------
        let (store4, suite4, name4) = makeIsolatedStore()
        suite4.removeObject(forKey: store4.keys.displayMode)
        suite4.removeObject(forKey: store4.keys.bothDirectionsStyle)
        suite4.removeObject(forKey: store4.keys.manualDirection)
        suite4.removeObject(forKey: store4.keys.launchAtLogin)

        assert(store4.getDisplayMode() == .bothDirections, "Missing displayMode must return .bothDirections")
        assert(store4.getBothDirectionsStyle() == .separateSpeeds, "Missing bothDirectionsStyle must return .separateSpeeds")
        assert(store4.getManualDirection() == .download, "Missing manualDirection must return .download")
        assert(store4.getLaunchAtLogin() == false, "Missing launchAtLogin must return false")
        suite4.removePersistentDomain(forName: name4)
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Invalid enum values recovery and auto-repair
        // ---------------------------------------------------------------------
        let (store5, suite5, name5) = makeIsolatedStore()

        // Corrupt displayMode
        suite5.set("corruptedDisplayModeValue", forKey: store5.keys.displayMode)
        assert(store5.getDisplayMode() == .bothDirections, "Invalid displayMode must fall back to .bothDirections")
        let repairedMode = suite5.string(forKey: store5.keys.displayMode)
        assert(repairedMode == DisplayMode.bothDirections.rawValue, "Invalid displayMode must be repaired in storage")

        // Corrupt bothDirectionsStyle
        suite5.set("unknownStyle999", forKey: store5.keys.bothDirectionsStyle)
        assert(store5.getBothDirectionsStyle() == .separateSpeeds, "Invalid bothDirectionsStyle must fall back to .separateSpeeds")
        let repairedStyle = suite5.string(forKey: store5.keys.bothDirectionsStyle)
        assert(repairedStyle == BothDirectionsStyle.separateSpeeds.rawValue, "Invalid bothDirectionsStyle must be repaired in storage")

        // Corrupt manualDirection
        suite5.set("invalidDirection", forKey: store5.keys.manualDirection)
        assert(store5.getManualDirection() == .download, "Invalid manualDirection must fall back to .download")
        let repairedDir = suite5.string(forKey: store5.keys.manualDirection)
        assert(repairedDir == NetworkDirection.download.rawValue, "Invalid manualDirection must be repaired in storage")

        // Corrupt launchAtLogin with invalid non-boolean object
        suite5.set("notABooleanValue", forKey: store5.keys.launchAtLogin)
        assert(store5.getLaunchAtLogin() == false, "Invalid launchAtLogin must fall back to false")

        suite5.removePersistentDomain(forName: name5)
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: Independent preference updates without overwriting others
        // ---------------------------------------------------------------------
        let (store6, suite6, name6) = makeIsolatedStore()
        store6.savePreferences(AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .download,
            launchAtLogin: false
        ))

        // Update displayMode only
        store6.setDisplayMode(.singleDirectionManual)
        assert(store6.getDisplayMode() == .singleDirectionManual, "displayMode must be updated")
        assert(store6.getBothDirectionsStyle() == .separateSpeeds, "bothDirectionsStyle must remain unchanged")
        assert(store6.getManualDirection() == .download, "manualDirection must remain unchanged")
        assert(store6.getLaunchAtLogin() == false, "launchAtLogin must remain unchanged")

        // Update manualDirection only
        store6.setManualDirection(.upload)
        assert(store6.getDisplayMode() == .singleDirectionManual, "displayMode must remain unchanged")
        assert(store6.getBothDirectionsStyle() == .separateSpeeds, "bothDirectionsStyle must remain unchanged")
        assert(store6.getManualDirection() == .upload, "manualDirection must be updated")
        assert(store6.getLaunchAtLogin() == false, "launchAtLogin must remain unchanged")

        // Update launchAtLogin only
        store6.setLaunchAtLogin(true)
        assert(store6.getDisplayMode() == .singleDirectionManual, "displayMode must remain unchanged")
        assert(store6.getBothDirectionsStyle() == .separateSpeeds, "bothDirectionsStyle must remain unchanged")
        assert(store6.getManualDirection() == .upload, "manualDirection must remain unchanged")
        assert(store6.getLaunchAtLogin() == true, "launchAtLogin must be updated")

        suite6.removePersistentDomain(forName: name6)
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: resetToDefaults restores all preferences
        // ---------------------------------------------------------------------
        let (store7, suite7, name7) = makeIsolatedStore()
        store7.savePreferences(AppPreferences(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: true
        ))
        assert(store7.loadPreferences() != .default, "Preferences must be non-default before reset")

        store7.resetToDefaults()
        assert(store7.loadPreferences() == .default, "resetToDefaults() must restore all values to AppPreferences.default")
        suite7.removePersistentDomain(forName: name7)
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: Async protocol conformance
        // ---------------------------------------------------------------------
        let (store8, suite8, name8) = makeIsolatedStore()
        let customAsync = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: true
        )
        let storing: any PreferencesStoring = store8
        try await storing.savePreferences(customAsync)
        let loadedAsync = await storing.loadPreferences()
        assert(loadedAsync == customAsync, "Async loadPreferences must match saved model")
        suite8.removePersistentDomain(forName: name8)
        count += 1

        return count
    }
}
