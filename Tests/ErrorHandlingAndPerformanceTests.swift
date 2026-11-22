import Foundation
import AppKit

/// Comprehensive test suite for Phase 13: Error Handling & Performance Optimization.
///
/// Tests interface retrieval failures, disconnection and reconnection recovery,
/// counter discontinuity handling, timing boundary enforcement, concurrency isolation,
/// menu-bar redundant render suppression, and transient memory guarantees.
public enum ErrorHandlingAndPerformanceTests {
    @MainActor
    public static func run() async throws -> Int {
        var count = 0

        let wifi = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)
        let ethernet = NetworkInterface(name: "en1", index: 2, type: .ethernet, isUsable: true)

        // ---------------------------------------------------------------------
        // Test 1: Interface statistics retrieval failure handling in NetworkPathManager
        // ---------------------------------------------------------------------
        let mockProvider = MockNetworkInterfaceProvider()
        let pathManager = NetworkPathManager(interfaceProvider: mockProvider)
        try await pathManager.startMonitoring()

        await mockProvider.setError(.enumerationFailed(errno: 5))
        let failedSnap = try? await pathManager.sampleCurrentSnapshot()

        assert(failedSnap == nil, "Failed statistics enumeration must return nil snapshot")
        let selectionResult = await pathManager.currentSelectionResult
        if case .enumerationFailed = selectionResult {
            // expected
        } else {
            assertionFailure("Selection result must be .enumerationFailed, got \(selectionResult)")
        }
        let currentSnap = await pathManager.currentSnapshot
        assert(currentSnap == nil, "currentSnapshot must be cleared to nil on enumeration failure")
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Recovery when healthy statistics resume
        // ---------------------------------------------------------------------
        await mockProvider.setError(nil)
        let stat0 = NetworkInterfaceStatistics(
            name: "en0",
            index: 1,
            type: .wifi,
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            isUp: true,
            isRunning: true,
            isLoopback: false
        )
        await mockProvider.setStatistics([stat0])
        await pathManager.handlePathUpdate(.satisfiedWiFi, sessionID: 1)

        let recoveredSnap = try? await pathManager.sampleCurrentSnapshot()
        assert(recoveredSnap != nil, "Snapshot must be recovered after healthy statistics return")
        let recoveredSelection = await pathManager.currentSelectionResult
        assert(recoveredSelection.isSelected, "Interface must be selected after recovery")
        await pathManager.stopMonitoring()
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Disconnection resets snapshot and clears baseline in Coordinator
        // ---------------------------------------------------------------------
        let suiteName = "in.arrry.test.hardening.\(UUID().uuidString)"
        guard let suite = UserDefaults(suiteName: suiteName) else {
            fatalError("Failed to create isolated UserDefaults")
        }
        suite.removePersistentDomain(forName: suiteName)
        let store = PreferencesStore(userDefaults: suite)
        let mockMonitor = MockNetworkMonitor()
        let coordinator = ApplicationCoordinator(
            preferencesStore: store,
            networkMonitor: mockMonitor
        )
        await coordinator.start()

        // Establish active path and baseline
        await mockMonitor.simulatePathUpdate(.satisfiedWiFi)
        try? await Task.sleep(nanoseconds: 10_000_000)

        let snap1 = NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap1)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Snapshot 2: produces valid speed
        let snap2 = NetworkSnapshot(
            receivedBytes: 10_500_000,
            transmittedBytes: 5_250_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snap2)
        try? await Task.sleep(nanoseconds: 10_000_000)
        assert(coordinator.latestMeasurement != nil, "Coordinator must have latestMeasurement when connected")

        // Disconnect network
        await mockMonitor.simulatePathUpdate(.unsatisfied)
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(coordinator.pathState.status == .unsatisfied, "Path state must be unsatisfied")
        assert(coordinator.speedResult == .noActivePath, "Speed result must be .noActivePath")
        assert(coordinator.latestMeasurement == nil, "latestMeasurement must be nil when disconnected")
        assert(coordinator.dominantDirection == .download, "Dominant direction must reset to .download")
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Reconnection establishes fresh baseline without calculating across gap
        // ---------------------------------------------------------------------
        await mockMonitor.simulatePathUpdate(.satisfiedWiFi)
        try? await Task.sleep(nanoseconds: 10_000_000)

        // First sample after reconnection at t = 10s (gap of 8 seconds)
        let snapReconnect1 = NetworkSnapshot(
            receivedBytes: 20_000_000,
            transmittedBytes: 10_000_000,
            monotonicTimeNanoseconds: 10_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snapReconnect1)
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(coordinator.speedResult == .baselineEstablished, "Reconnection sample 1 must establish fresh baseline")
        assert(coordinator.latestMeasurement == nil, "No measurement produced during baseline establishment")

        // Second sample at t = 11s (1s delta)
        let snapReconnect2 = NetworkSnapshot(
            receivedBytes: 20_200_000, // 200 KB/s
            transmittedBytes: 10_100_000, // 100 KB/s
            monotonicTimeNanoseconds: 11_000_000_000,
            interface: wifi
        )
        await mockMonitor.simulateSnapshotUpdate(snapReconnect2)
        try? await Task.sleep(nanoseconds: 10_000_000)

        guard let reconnectedMeasurement = coordinator.latestMeasurement else {
            assertionFailure("Measurement must exist after second sample")
            return count
        }
        assert(reconnectedMeasurement.downloadBytesPerSecond == 200_000, "Must calculate 200 KB/s from clean 1s delta")
        assert(reconnectedMeasurement.uploadBytesPerSecond == 100_000, "Must calculate 100 KB/s from clean 1s delta")
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Counter decrease / reset triggers baseline reset and clears speed
        // ---------------------------------------------------------------------
        let calc5 = NetworkSpeedCalculator()
        _ = await calc5.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        ))
        let res5 = await calc5.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 5_000_000, // Counter decreased! (kernel reset or rollover)
            transmittedBytes: 2_500_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifi
        ))
        assert(res5 == .baselineReset(reason: .counterDecreased), "Decreased counter must trigger baselineReset(.counterDecreased)")
        assert(res5.measurement == nil, "No measurement on counter decrease")
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: Interface transition triggers baseline reset
        // ---------------------------------------------------------------------
        let calc6 = NetworkSpeedCalculator()
        _ = await calc6.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        ))
        let res6 = await calc6.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 2_000_000,
            transmittedBytes: 1_000_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: ethernet // Interface changed!
        ))
        assert(res6 == .baselineReset(reason: .interfaceChanged), "Interface transition must trigger baselineReset(.interfaceChanged)")
        assert(res6.measurement == nil, "No measurement across different interfaces")
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: Maximum interval limit resets baseline (sleep/suspension recovery)
        // ---------------------------------------------------------------------
        let calc7 = NetworkSpeedCalculator(maximumMeasurementIntervalSeconds: 5.0)
        _ = await calc7.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000, // t = 1.0s
            interface: wifi
        ))
        // Sample arriving after 8.0s elapsed (> 5.0s max limit)
        let res7 = await calc7.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 50_000_000,
            transmittedBytes: 25_000_000,
            monotonicTimeNanoseconds: 9_000_000_000, // t = 9.0s (8s later)
            interface: wifi
        ))
        assert(res7 == .baselineReset(reason: .intervalTooLong), "Elapsed interval > 5s must trigger baselineReset(.intervalTooLong)")

        // Next sample arriving at normal 1s interval (t = 10.0s)
        let res7b = await calc7.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 50_200_000,
            transmittedBytes: 25_100_000,
            monotonicTimeNanoseconds: 10_000_000_000, // t = 10.0s (1s later)
            interface: wifi
        ))
        if case .calculated(let m7) = res7b {
            assert(m7.elapsedSeconds == 1.0, "Subsequent sample must calculate speed from refreshed baseline")
            assert(m7.downloadBytesPerSecond == 200_000, "Expected 200 KB/s")
        } else {
            assertionFailure("Expected calculated speed after interval reset")
        }
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: Non-monotonic reversed timestamp rejection without corrupting baseline
        // ---------------------------------------------------------------------
        let calc8 = NetworkSpeedCalculator()
        _ = await calc8.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 5_000_000_000,
            interface: wifi
        ))
        let res8 = await calc8.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_100_000,
            transmittedBytes: 550_000,
            monotonicTimeNanoseconds: 4_000_000_000, // Earlier timestamp!
            interface: wifi
        ))
        assert(res8 == .sampleRejected(reason: .reversedTimestamp), "Reversed timestamp must be rejected")

        // Subsequent valid sample 1s after baseline
        let res8b = await calc8.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_100_000,
            transmittedBytes: 550_000,
            monotonicTimeNanoseconds: 6_000_000_000, // 1s after 5s
            interface: wifi
        ))
        if case .calculated(let m8) = res8b {
            assert(m8.downloadBytesPerSecond == 100_000, "Must calculate against preserved baseline")
        } else {
            assertionFailure("Baseline must be preserved after rejected sample")
        }
        count += 1

        // ---------------------------------------------------------------------
        // Test 9: DominantDirectionEngine non-finite input protection
        // ---------------------------------------------------------------------
        let engine9 = DominantDirectionEngine()
        let nanMeasurement = SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: Double.nan),
            upload: NetworkSpeed(bytesPerSecond: Double.infinity),
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifi
        )
        let decision9 = await engine9.evaluate(nanMeasurement)
        assert(decision9.direction == .download, "Non-finite speeds must settle on default .download")
        assert(!decision9.didSwitch, "Non-finite speeds must not trigger switch")
        let pending9 = await engine9.pendingCandidate
        assert(pending9 == nil, "Pending candidate must be nil on non-finite input")
        count += 1

        // ---------------------------------------------------------------------
        // Test 10: MenuBarManager change detection skips redundant AppKit renders
        // ---------------------------------------------------------------------
        let menuBarManager = MenuBarManager(coordinator: coordinator)
        menuBarManager.start()

        let initialRenderCount = menuBarManager.renderCount
        assert(initialRenderCount >= 1, "Initial render must occur on start()")

        // Calling updateContent() with identical state must be a no-op
        menuBarManager.updateContent()
        menuBarManager.updateContent()
        menuBarManager.updateContent()

        assert(menuBarManager.renderCount == initialRenderCount, "Redundant updateContent() with identical content must NOT increment renderCount")
        count += 1

        // ---------------------------------------------------------------------
        // Test 11: MenuBarManager increments renderCount when content actually changes
        // ---------------------------------------------------------------------
        // Change preferences to trigger visible content change
        coordinator.applyPreferences(AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .upload,
            launchAtLogin: false
        ))
        try? await Task.sleep(nanoseconds: 10_000_000)

        assert(menuBarManager.renderCount > initialRenderCount, "Changed display content must increment renderCount")
        let updatedRenderCount = menuBarManager.renderCount

        // Calling updateContent() again with unchanged state must not increment
        menuBarManager.updateContent()
        assert(menuBarManager.renderCount == updatedRenderCount, "Subsequent identical updateContent() must not increment renderCount")
        menuBarManager.stop()
        count += 1

        // ---------------------------------------------------------------------
        // Test 12: Transient memory & persistent storage privacy verification
        // ---------------------------------------------------------------------
        // Verify that only the 4 approved configuration keys exist in storage
        let allKeys = Array(suite.dictionaryRepresentation().keys).filter {
            $0.hasPrefix("in.arrry.networkcounter")
        }
        for key in allKeys {
            assert(
                key == AppConfiguration.PersistenceKeys.preferences ||
                key == AppConfiguration.PersistenceKeys.displayMode ||
                key == AppConfiguration.PersistenceKeys.bothDirectionsStyle ||
                key == AppConfiguration.PersistenceKeys.manualDirection ||
                key == AppConfiguration.PersistenceKeys.launchAtLogin,
                "Unauthorized key found in persistent storage: \(key)"
            )
        }
        // Verify zero historical traffic logs exist
        assert(!suite.dictionaryRepresentation().keys.contains(where: { $0.contains("history") || $0.contains("traffic") }), "No historical traffic logs may be stored")
        count += 1

        // Cleanup
        await coordinator.stop()
        suite.removePersistentDomain(forName: suiteName)

        return count
    }
}
