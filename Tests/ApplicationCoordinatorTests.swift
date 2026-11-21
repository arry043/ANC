import Foundation

/// Mock implementation of `PreferencesStoring` for coordinator unit testing.
public actor MockPreferencesStore: PreferencesStoring {
    public var storedPreferences: AppPreferences
    public var loadCount: Int = 0
    public var saveCount: Int = 0

    public init(initialPreferences: AppPreferences = .default) {
        self.storedPreferences = initialPreferences
    }

    public func loadPreferences() async -> AppPreferences {
        loadCount += 1
        return storedPreferences
    }

    public func savePreferences(_ preferences: AppPreferences) async throws {
        saveCount += 1
        self.storedPreferences = preferences
    }
}

/// Mock implementation of `NetworkMonitoring` for coordinator unit testing.
public actor MockNetworkMonitor: NetworkMonitoring {
    public var isMonitoring: Bool = false
    public var currentSnapshot: NetworkSnapshot? = nil
    public var startCount: Int = 0
    public var stopCount: Int = 0

    public var snapshotStream: AsyncStream<NetworkSnapshot> {
        AsyncStream { _ in }
    }

    public func startMonitoring() async throws {
        startCount += 1
        isMonitoring = true
    }

    public func stopMonitoring() async {
        stopCount += 1
        isMonitoring = false
    }
}

/// Unit test suite for `ApplicationCoordinator` and mock protocol interactions.
public enum ApplicationCoordinatorTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        // Test 1: Coordinator initialization with initial defaults
        let mockStore = MockPreferencesStore()
        let mockMonitor = MockNetworkMonitor()
        let coordinator = ApplicationCoordinator(
            preferencesStore: mockStore,
            networkMonitor: mockMonitor
        )
        assert(!coordinator.isRunning, "Coordinator must not be running before start()")
        assert(coordinator.preferences == .default, "Initial preferences must equal default")
        count += 1

        // Test 2: Coordinator start() loads preferences and initiates monitor
        await coordinator.start()
        assert(coordinator.isRunning, "Coordinator must be running after start()")
        let loadCount = await mockStore.loadCount
        let startCount = await mockMonitor.startCount
        assert(loadCount == 1, "Preferences must be loaded exactly once during start()")
        assert(startCount == 1, "Monitoring must be started exactly once")
        count += 1

        // Test 3: Idempotent start()
        await coordinator.start()
        let loadCount2 = await mockStore.loadCount
        assert(loadCount2 == 1, "Subsequent start() call while running must be a no-op")
        count += 1

        // Test 4: updatePreferences() saves and updates published state
        let updated = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: true
        )
        try await coordinator.updatePreferences(updated)
        assert(coordinator.preferences == updated, "Published preferences must reflect updated value")
        let saveCount = await mockStore.saveCount
        let saved = await mockStore.storedPreferences
        assert(saveCount == 1, "Store saveCount must increment")
        assert(saved == updated, "Saved preferences in store must match updated values")
        count += 1

        // Test 5: stop() terminates monitoring
        await coordinator.stop()
        assert(!coordinator.isRunning, "Coordinator must not be running after stop()")
        let stopCount = await mockMonitor.stopCount
        let isMon = await mockMonitor.isMonitoring
        assert(stopCount == 1, "Monitor must receive exactly one stop call")
        assert(!isMon, "Monitor state must be false")
        count += 1

        return count
    }
}
