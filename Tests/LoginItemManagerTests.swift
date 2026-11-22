import Foundation

/// Unit test suite for `LoginItemManager` and ServiceManagement registration scenarios.
public enum LoginItemManagerTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        func makeTestManager(initialStatus: LoginItemStatus = .notRegistered) -> (LoginItemManager, MockLoginItemProvider, PreferencesStore, UserDefaults, String) {
            let suiteName = "in.arrry.test.loginitem.\(UUID().uuidString)"
            guard let suite = UserDefaults(suiteName: suiteName) else {
                fatalError("Failed to create isolated suite")
            }
            suite.removePersistentDomain(forName: suiteName)
            let store = PreferencesStore(userDefaults: suite)
            let mockProvider = MockLoginItemProvider(initialStatus: initialStatus)
            let manager = LoginItemManager(provider: mockProvider, preferencesStore: store)
            return (manager, mockProvider, store, suite, suiteName)
        }

        // ---------------------------------------------------------------------
        // Test 1: Initial status reflection from provider and sync to store
        // ---------------------------------------------------------------------
        let (mgr1A, _, store1A, suite1A, name1A) = makeTestManager(initialStatus: .notRegistered)
        assert(mgr1A.status == .notRegistered, "Initial status must reflect .notRegistered")
        assert(!mgr1A.isEnabled, "isEnabled must be false when not registered")
        assert(store1A.getLaunchAtLogin() == false, "Store must synchronize to false")
        suite1A.removePersistentDomain(forName: name1A)

        let (mgr1B, _, store1B, suite1B, name1B) = makeTestManager(initialStatus: .enabled)
        assert(mgr1B.status == .enabled, "Initial status must reflect .enabled")
        assert(mgr1B.isEnabled, "isEnabled must be true when enabled")
        assert(store1B.getLaunchAtLogin() == true, "Store must synchronize to true")
        suite1B.removePersistentDomain(forName: name1B)
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Registration success transitions status and updates store
        // ---------------------------------------------------------------------
        let (mgr2, provider2, store2, suite2, name2) = makeTestManager(initialStatus: .notRegistered)
        try await mgr2.setEnabled(true)
        assert(provider2.registerCount == 1, "Provider register must be called exactly once")
        assert(mgr2.status == .enabled, "Manager status must become .enabled")
        assert(mgr2.isEnabled, "isEnabled must be true after registration")
        assert(store2.getLaunchAtLogin() == true, "Store must be updated to true")
        assert(mgr2.lastErrorMessage == nil, "Error message must be nil on success")
        suite2.removePersistentDomain(forName: name2)
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Unregistration success transitions status and updates store
        // ---------------------------------------------------------------------
        let (mgr3, provider3, store3, suite3, name3) = makeTestManager(initialStatus: .enabled)
        try await mgr3.setEnabled(false)
        assert(provider3.unregisterCount == 1, "Provider unregister must be called exactly once")
        assert(mgr3.status == .notRegistered, "Manager status must become .notRegistered")
        assert(!mgr3.isEnabled, "isEnabled must be false after unregistration")
        assert(store3.getLaunchAtLogin() == false, "Store must be updated to false")
        suite3.removePersistentDomain(forName: name3)
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Idempotent registration avoids redundant calls
        // ---------------------------------------------------------------------
        let (mgr4, provider4, _, suite4, name4) = makeTestManager(initialStatus: .enabled)
        try await mgr4.setEnabled(true)
        assert(provider4.registerCount == 0, "Enabling when already enabled must not call provider register")
        assert(mgr4.status == .enabled, "Status must remain .enabled")
        suite4.removePersistentDomain(forName: name4)
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Idempotent unregistration avoids redundant calls
        // ---------------------------------------------------------------------
        let (mgr5, provider5, _, suite5, name5) = makeTestManager(initialStatus: .notRegistered)
        try await mgr5.setEnabled(false)
        assert(provider5.unregisterCount == 0, "Disabling when already not registered must not call provider unregister")
        assert(mgr5.status == .notRegistered, "Status must remain .notRegistered")
        suite5.removePersistentDomain(forName: name5)
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: Registration failure propagates error and restores status
        // ---------------------------------------------------------------------
        let (mgr6, provider6, store6, suite6, name6) = makeTestManager(initialStatus: .notRegistered)
        struct TestError: Error, LocalizedError {
            var errorDescription: String? { "Operation not permitted" }
        }
        provider6.shouldThrowOnRegister = TestError()

        var caughtError: Error? = nil
        do {
            try await mgr6.setEnabled(true)
        } catch {
            caughtError = error
        }
        assert(caughtError != nil, "Registration failure must throw")
        assert(provider6.registerCount == 1, "Provider register was attempted")
        assert(mgr6.status == .notRegistered, "Status must remain .notRegistered after failed registration")
        assert(!mgr6.isEnabled, "isEnabled must remain false")
        assert(store6.getLaunchAtLogin() == false, "Store must not report false success")
        assert(mgr6.lastErrorMessage?.contains("Operation not permitted") == true, "Error message must be populated")
        suite6.removePersistentDomain(forName: name6)
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: Unregistration failure propagates error
        // ---------------------------------------------------------------------
        let (mgr7, provider7, store7, suite7, name7) = makeTestManager(initialStatus: .enabled)
        provider7.shouldThrowOnUnregister = TestError()

        var caughtUnregError: Error? = nil
        do {
            try await mgr7.setEnabled(false)
        } catch {
            caughtUnregError = error
        }
        assert(caughtUnregError != nil, "Unregistration failure must throw")
        assert(provider7.unregisterCount == 1, "Provider unregister was attempted")
        assert(mgr7.status == .enabled, "Status must remain .enabled after failed unregistration")
        assert(store7.getLaunchAtLogin() == true, "Store must remain true after failed unregistration")
        suite7.removePersistentDomain(forName: name7)
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: Status requiresApproval is reported and opens system settings
        // ---------------------------------------------------------------------
        let (mgr8, provider8, _, suite8, name8) = makeTestManager(initialStatus: .requiresApproval)
        assert(mgr8.status == .requiresApproval, "Status must reflect .requiresApproval")
        assert(!mgr8.isEnabled, "requiresApproval is not considered enabled until approved")

        mgr8.openSystemSettings()
        assert(provider8.openSettingsCount == 1, "openSystemSettings must call provider")
        suite8.removePersistentDomain(forName: name8)
        count += 1

        // ---------------------------------------------------------------------
        // Test 9: Status notFound handling without crashing
        // ---------------------------------------------------------------------
        let (mgr9, _, _, suite9, name9) = makeTestManager(initialStatus: .notFound)
        assert(mgr9.status == .notFound, "Status must reflect .notFound")
        assert(!mgr9.isEnabled, "notFound must not be enabled")
        suite9.removePersistentDomain(forName: name9)
        count += 1

        // ---------------------------------------------------------------------
        // Test 10: SettingsManager synchronization with LoginItemManager
        // ---------------------------------------------------------------------
        let suiteName10 = "in.arrry.test.loginitem.sync.\(UUID().uuidString)"
        guard let suite10 = UserDefaults(suiteName: suiteName10) else {
            fatalError("Failed to create isolated suite")
        }
        suite10.removePersistentDomain(forName: suiteName10)
        let store10 = PreferencesStore(userDefaults: suite10)
        let mockProvider10 = MockLoginItemProvider(initialStatus: .notRegistered)
        let loginMgr10 = LoginItemManager(provider: mockProvider10, preferencesStore: store10)
        let coordinator10 = ApplicationCoordinator(preferencesStore: store10)
        let settingsMgr10 = SettingsManager(
            coordinator: coordinator10,
            preferencesStore: store10,
            loginItemManager: loginMgr10
        )

        assert(settingsMgr10.preferences.launchAtLogin == false, "Initial setting must be false")
        assert(!settingsMgr10.loginItemManager.isEnabled, "LoginItemManager must be disabled")

        await settingsMgr10.updateLaunchAtLogin(true)
        assert(mockProvider10.registerCount == 1, "SettingsManager must delegate to login item manager")
        assert(settingsMgr10.loginItemManager.isEnabled == true, "LoginItemManager must be enabled")
        assert(settingsMgr10.preferences.launchAtLogin == true, "Settings preferences must update")
        assert(coordinator10.preferences.launchAtLogin == true, "Coordinator preferences must update")
        assert(store10.getLaunchAtLogin() == true, "Store must be persisted")

        await settingsMgr10.updateLaunchAtLogin(false)
        assert(mockProvider10.unregisterCount == 1, "SettingsManager must unregister")
        assert(settingsMgr10.loginItemManager.isEnabled == false, "LoginItemManager must be disabled")
        assert(settingsMgr10.preferences.launchAtLogin == false, "Settings preferences must update to false")

        suite10.removePersistentDomain(forName: suiteName10)
        count += 1

        return count
    }
}
