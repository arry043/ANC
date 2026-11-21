import AppKit

/// Unit test suite for `MenuBarManager` and status item lifecycle.
public enum MenuBarManagerTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        let mockStore = MockPreferencesStore()
        let mockMonitor = MockNetworkMonitor()
        let coordinator = ApplicationCoordinator(
            preferencesStore: mockStore,
            networkMonitor: mockMonitor
        )
        let manager = MenuBarManager(coordinator: coordinator)

        // Test 1: Initial state before start()
        assert(!manager.isRunning, "Manager must not be running initially")
        assert(manager.statusItem == nil, "Status item must be nil before start()")
        assert(manager.lastRenderedContent == nil, "lastRenderedContent must be nil initially")
        count += 1

        // Test 2: start() creates status item and initializes content
        manager.start()
        assert(manager.isRunning, "Manager must be running after start()")
        assert(manager.statusItem != nil, "statusItem must be created after start()")
        assert(manager.lastRenderedContent != nil, "lastRenderedContent must be populated after start()")
        let initialItem = manager.statusItem
        count += 1

        // Test 3: Idempotent start() does not recreate statusItem
        manager.start()
        assert(manager.statusItem === initialItem, "Subsequent start() must not recreate statusItem")
        count += 1

        // Test 4: Menu configuration verification
        guard let menu = manager.statusItem?.menu else {
            assertionFailure("Status item must have an attached NSMenu")
            return count
        }
        assert(menu.items.count == 3, "Menu must have 3 items (Settings, separator, Quit)")
        let settingsItem = menu.items[0]
        assert(settingsItem.title == "Settings...", "First menu item must be 'Settings...'")
        assert(settingsItem.keyEquivalent == ",", "Settings key equivalent must be ','")
        assert(settingsItem.action == #selector(MenuBarManager.handleSettingsAction), "Settings action must be handleSettingsAction")

        assert(menu.items[1].isSeparatorItem, "Second item must be a separator")

        let quitItem = menu.items[2]
        assert(quitItem.title == "Quit ARRY Network Counter", "Third item must be 'Quit ARRY Network Counter'")
        assert(quitItem.keyEquivalent == "q", "Quit key equivalent must be 'q'")
        assert(quitItem.action == #selector(MenuBarManager.handleQuitAction), "Quit action must be handleQuitAction")
        count += 1

        // Test 5: updateContent() sets button attributedTitle and accessibility label
        if let button = manager.statusItem?.button {
            let title = button.attributedTitle.string
            assert(!title.isEmpty, "Status item button must have non-empty attributed title")
            assert(title.contains("↓") && title.contains("↑"), "Attributed title must contain direction arrows")
            let accLabel = button.accessibilityLabel() ?? ""
            assert(accLabel == title, "Button accessibility label must match rendered title")
        } else {
            assertionFailure("Status item must have a valid button")
        }
        count += 1

        // Test 6: stop() cleans up status item and state
        manager.stop()
        assert(!manager.isRunning, "Manager must not be running after stop()")
        assert(manager.statusItem == nil, "statusItem must be nil after stop()")
        assert(manager.lastRenderedContent == nil, "lastRenderedContent must be nil after stop()")
        count += 1

        return count
    }
}
