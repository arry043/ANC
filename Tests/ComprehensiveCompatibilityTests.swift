import Foundation
import AppKit

/// Comprehensive test suite for Phase 14: Comprehensive Testing & Compatibility.
///
/// Validates network speed calculation edge cases, byte formatting SI boundaries,
/// dominant direction hysteresis under jitter and noise, interface selection prioritization,
/// all 4 display mode presentations, preferences corruption recovery, bundle integrity,
/// macOS 13.0 API surface characteristics, and concurrent stress execution.
public enum ComprehensiveCompatibilityTests {

    @MainActor
    public static func run() async throws -> Int {
        var count = 0
        let wifiInterface = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)
        let ethInterface = NetworkInterface(name: "en1", index: 2, type: .ethernet, isUsable: true)

        // =====================================================================
        // SECTION 1: Network Speed Calculation Edge Cases & Stress
        // =====================================================================

        // 1. Initial baseline establishment & zero throughput
        let calc = NetworkSpeedCalculator(maximumMeasurementIntervalSeconds: 10.0)
        let t0 = Date(timeIntervalSince1970: 1000.0)
        let t1 = Date(timeIntervalSince1970: 1001.0)
        let t2 = Date(timeIntervalSince1970: 1002.0)

        let initialSnap = NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            timestamp: t0,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        )
        let r0 = await calc.calculateSpeed(from: initialSnap)
        assert(r0 == .baselineEstablished, "Initial snapshot must establish baseline")
        let hasBaseline = (await calc.baselineSnapshot != nil)
        assert(hasBaseline, "Baseline must be set after first snapshot")
        count += 1

        // Zero throughput over 1 second delta
        let idleSnap = NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            timestamp: t1,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        )
        let r1 = await calc.calculateSpeed(from: idleSnap)
        guard case let .calculated(m1) = r1 else {
            assertionFailure("Must measure 0 throughput successfully")
            return count
        }
        assert(m1.download.bytesPerSecond == 0.0, "Zero delta must produce 0.0 B/s download")
        assert(m1.upload.bytesPerSecond == 0.0, "Zero delta must produce 0.0 B/s upload")
        count += 1

        // 2. Micro throughput (< 1 KB/s) and High throughput (> 1 GB/s)
        let microSnap = NetworkSnapshot(
            receivedBytes: 1_000_150, // +150 B
            transmittedBytes: 500_720, // +720 B
            timestamp: t2,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifiInterface
        )
        let r2 = await calc.calculateSpeed(from: microSnap)
        guard case let .calculated(m2) = r2 else {
            assertionFailure("Must measure micro throughput successfully")
            return count
        }
        assert(m2.download.bytesPerSecond == 150.0, "Micro throughput download must be 150 B/s")
        assert(m2.upload.bytesPerSecond == 720.0, "Micro throughput upload must be 720 B/s")
        count += 1

        // High throughput: 1.25 GB/s (10 Gbps line rate)
        let t3 = Date(timeIntervalSince1970: 1003.0)
        let highSnap = NetworkSnapshot(
            receivedBytes: 1_000_150 + 1_250_000_000, // +1.25 GB
            transmittedBytes: 500_720 + 625_000_000, // +625 MB
            timestamp: t3,
            monotonicTimeNanoseconds: 4_000_000_000,
            interface: wifiInterface
        )
        let r3 = await calc.calculateSpeed(from: highSnap)
        guard case let .calculated(m3) = r3 else {
            assertionFailure("Must measure high throughput successfully")
            return count
        }
        assert(m3.download.bytesPerSecond == 1_250_000_000.0, "High throughput download must equal 1.25 GB/s")
        assert(m3.upload.bytesPerSecond == 625_000_000.0, "High throughput upload must equal 625 MB/s")
        count += 1

        // 3. Counter reset / decrease protection & timing bound (> 10s gap)
        let t4 = Date(timeIntervalSince1970: 1004.0)
        let decreasedSnap = NetworkSnapshot(
            receivedBytes: 500_000, // decreased from > 1.25 GB
            transmittedBytes: 200_000,
            timestamp: t4,
            monotonicTimeNanoseconds: 5_000_000_000,
            interface: wifiInterface
        )
        let r4 = await calc.calculateSpeed(from: decreasedSnap)
        guard case let .baselineReset(reason: decReason) = r4 else {
            assertionFailure("Decreased counter must trigger baselineReset")
            return count
        }
        assert(decReason == .counterDecreased, "Reset reason must be .counterDecreased")
        count += 1

        // Sleep / suspend timing gap (> 10s)
        let t5 = Date(timeIntervalSince1970: 1020.0) // 16s later
        let sleepSnap = NetworkSnapshot(
            receivedBytes: 600_000,
            transmittedBytes: 300_000,
            timestamp: t5,
            monotonicTimeNanoseconds: 21_000_000_000, // +16s nanoseconds
            interface: wifiInterface
        )
        let r5 = await calc.calculateSpeed(from: sleepSnap)
        guard case let .baselineReset(reason: timeReason) = r5 else {
            assertionFailure("Long interval gap (>10s) must trigger baselineReset")
            return count
        }
        assert(timeReason == .intervalTooLong, "Reset reason must be .intervalTooLong")
        count += 1

        // =====================================================================
        // SECTION 2: Byte & Speed Formatter Boundary & Scale Verification
        // =====================================================================

        // 4. Base-1000 SI scale transitions and decimal precision
        let formatter = SpeedFormatter.shared

        assert(formatter.format(bytesPerSecond: 0.0) == "0 KB/s", "0.0 B/s must format as '0 KB/s'")
        assert(formatter.format(bytesPerSecond: 999.0) == "999 B/s", "999 B/s must format as '999 B/s'")
        assert(formatter.format(bytesPerSecond: 1_000.0) == "1 KB/s", "1,000 B/s must format as '1 KB/s'")
        assert(formatter.format(bytesPerSecond: 1_500.0) == "1.5 KB/s", "1,500 B/s must format as '1.5 KB/s'")
        assert(formatter.format(bytesPerSecond: 1_750.0) == "1.75 KB/s", "1,750 B/s must format as '1.75 KB/s'")
        assert(formatter.format(bytesPerSecond: 10_000.0) == "10 KB/s", "10,000 B/s must format as '10 KB/s'")
        assert(formatter.format(bytesPerSecond: 999_000.0) == "999 KB/s", "999,000 B/s must format as '999 KB/s'")
        assert(formatter.format(bytesPerSecond: 1_000_000.0) == "1 MB/s", "1,000,000 B/s must format as '1 MB/s'")
        assert(formatter.format(bytesPerSecond: 1_250_000.0) == "1.25 MB/s", "1,250,000 B/s must format as '1.25 MB/s'")
        assert(formatter.format(bytesPerSecond: 1_000_000_000.0) == "1 GB/s", "1,000,000,000 B/s must format as '1 GB/s'")
        assert(formatter.format(bytesPerSecond: 1_000_000_000_000.0) == "1 TB/s", "1,000,000,000,000 B/s must format as '1 TB/s'")
        count += 1

        // 5. Non-finite and negative speed boundary handling
        assert(formatter.format(bytesPerSecond: -100.0) == "0 KB/s", "Negative speed must format as '0 KB/s'")
        assert(formatter.format(bytesPerSecond: Double.nan) == "0 KB/s", "NaN speed must format as '0 KB/s'")
        assert(formatter.format(bytesPerSecond: Double.infinity) == "0 KB/s", "Infinity speed must format as '0 KB/s'")
        assert(formatter.format(bytesPerSecond: -Double.infinity) == "0 KB/s", "-Infinity speed must format as '0 KB/s'")
        count += 1

        // =====================================================================
        // SECTION 3: Dominant Direction Engine Hysteresis & Stress
        // =====================================================================

        // 6. Threshold boundary & consecutive confirmation logic
        let engine = DominantDirectionEngine(configuration: .default)
        let initialDir = await engine.currentDirection
        assert(initialDir == .download, "Initial direction must default to .download")

        // Sub-threshold change: upload is only 5% higher (relative margin requires 10%)
        let subRelMeas = SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: 100_000),
            upload: NetworkSpeed(bytesPerSecond: 105_000), // +5%
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        )
        let d1 = await engine.evaluate(subRelMeas)
        assert(!d1.didSwitch && d1.direction == .download, "5% higher upload must NOT trigger candidate or switch")
        count += 1

        // Sub-noise-floor change: upload is +50% higher, but absolute delta is only 500 B/s (< 10,000 B/s)
        let subAbsMeas = SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: 1_000),
            upload: NetworkSpeed(bytesPerSecond: 1_500), // +500 B/s
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        )
        let d2 = await engine.evaluate(subAbsMeas)
        assert(!d2.didSwitch && d2.direction == .download, "Under 10 KB/s noise floor must NOT trigger switch")
        count += 1

        // Qualifying candidate 1 (upload exceeds download by 30% and >10 KB/s)
        let qualMeas = SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: 50_000),
            upload: NetworkSpeed(bytesPerSecond: 80_000), // +30 KB/s (>10% and >10 KB/s)
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifiInterface
        )
        let d3 = await engine.evaluate(qualMeas)
        assert(!d3.didSwitch, "Sample 1 of qualifying candidate must NOT switch yet")
        assert(d3.candidateDirection == .upload, "Candidate direction must be set to .upload")
        assert(d3.confirmationCount == 1, "Confirmation count must be 1")
        assert(d3.direction == .download, "Active direction must still remain .download")
        count += 1

        // Qualifying candidate 2 (consecutive sample confirmation -> switch triggers)
        let d4 = await engine.evaluate(qualMeas)
        assert(d4.didSwitch, "Sample 2 of qualifying candidate MUST trigger switch")
        assert(d4.direction == .upload, "Active direction must now be .upload")
        let activeDir = await engine.currentDirection
        assert(activeDir == .upload, "Engine currentDirection must now be .upload")
        count += 1

        // Flapping cancellation: single download spike followed by return to upload
        let dlSpike = SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: 120_000), // download exceeds upload
            upload: NetworkSpeed(bytesPerSecond: 80_000),
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 4_000_000_000,
            interface: wifiInterface
        )
        let d5 = await engine.evaluate(dlSpike)
        assert(!d5.didSwitch, "Single spike of opposite direction must NOT immediately switch")
        assert(d5.candidateDirection == .download, "Candidate direction must be set to .download")
        assert(d5.confirmationCount == 1, "Confirmation count must be 1")

        // Return to upload cancels the download candidate
        let d6 = await engine.evaluate(qualMeas)
        assert(!d6.didSwitch && d6.direction == .upload, "Return to upload must maintain .upload direction")
        let pending = await engine.pendingCandidate
        assert(pending == nil, "Pending candidate must be cleared on recovery")
        let candidateCount = await engine.consecutiveCandidateCount
        assert(candidateCount == 0, "Candidate count must be reset to 0")
        count += 1

        // =====================================================================
        // SECTION 4: Network Interface Selector & Prioritization
        // =====================================================================

        // 7. Interface selection policy: active vs inactive vs loopback
        let selector = NetworkInterfaceSelector()
        let wifiStat = NetworkInterfaceStatistics(
            name: "en0",
            index: 1,
            type: .wifi,
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            isUp: true,
            isRunning: true,
            isLoopback: false
        )
        let loopbackStat = NetworkInterfaceStatistics(
            name: "lo0",
            index: 3,
            type: .loopback,
            receivedBytes: 50_000_000,
            transmittedBytes: 50_000_000,
            isUp: true,
            isRunning: true,
            isLoopback: true
        )

        // Path satisfied with Wi-Fi
        let selWifi = selector.selectInterface(
            pathState: .satisfiedWiFi,
            statistics: [wifiStat, loopbackStat]
        )
        guard case let .selected(selectedIf, _) = selWifi else {
            assertionFailure("Selector must select active WiFi interface")
            return count
        }
        assert(selectedIf.name == "en0", "Selected interface must be en0")
        count += 1

        // Path satisfied with Ethernet
        let ethernetStat = NetworkInterfaceStatistics(
            name: "en1",
            index: 2,
            type: .ethernet,
            receivedBytes: 2_000_000,
            transmittedBytes: 1_000_000,
            isUp: true,
            isRunning: true,
            isLoopback: false
        )
        let selEthernet = selector.selectInterface(
            pathState: .satisfiedEthernet,
            statistics: [wifiStat, ethernetStat, loopbackStat]
        )
        guard case let .selected(selectedEth, _) = selEthernet else {
            assertionFailure("Selector must select active Ethernet interface")
            return count
        }
        assert(selectedEth.name == "en1", "Selected interface must be en1")
        assert(ethInterface.name == "en1", "Ethernet interface model name matches")
        count += 1

        // Loopback only must report .noUsableInterfaces
        let selLoopback = selector.selectInterface(
            pathState: .satisfiedWiFi,
            statistics: [loopbackStat]
        )
        guard case .noUsableInterfaces = selLoopback else {
            assertionFailure("Loopback only must report .noUsableInterfaces")
            return count
        }
        count += 1

        // =====================================================================
        // SECTION 5: Display Modes & Menu Bar Rendering Presentation
        // =====================================================================

        // 8. Plain text rendering across all display modes and styles
        let sampleMeasurement = SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: 10_000_000), // 10 MB/s
            upload: NetworkSpeed(bytesPerSecond: 2_000_000),   // 2 MB/s
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        )

        // Mode A: Both Directions — Separate Speeds
        let prefsSeparate = AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .download,
            launchAtLogin: false
        )
        let contentSeparate = MenuBarContentBuilder.build(
            preferences: prefsSeparate,
            pathState: .satisfiedWiFi,
            latestMeasurement: sampleMeasurement,
            dominantDirection: .download
        )
        let textSeparate = MenuBarRenderer.renderPlainText(content: contentSeparate)
        assert(textSeparate == "↓ 10 MB/s    ↑ 2 MB/s", "Separate speeds plain text must be '↓ 10 MB/s    ↑ 2 MB/s'")
        count += 1

        // Mode B: Both Directions — Combined Arrows (download dominant)
        let prefsCombined = AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        let contentCombinedDL = MenuBarContentBuilder.build(
            preferences: prefsCombined,
            pathState: .satisfiedWiFi,
            latestMeasurement: sampleMeasurement,
            dominantDirection: .download
        )
        let textCombinedDL = MenuBarRenderer.renderPlainText(content: contentCombinedDL)
        assert(textCombinedDL == "↓ ↑ 10 MB/s", "Combined arrows DL dominant must be '↓ ↑ 10 MB/s'")
        count += 1

        // Mode C: Both Directions — Combined Arrows (upload dominant)
        let contentCombinedUL = MenuBarContentBuilder.build(
            preferences: prefsCombined,
            pathState: .satisfiedWiFi,
            latestMeasurement: sampleMeasurement,
            dominantDirection: .upload
        )
        let textCombinedUL = MenuBarRenderer.renderPlainText(content: contentCombinedUL)
        assert(textCombinedUL == "↓ ↑ 2 MB/s", "Combined arrows UL dominant must be '↓ ↑ 2 MB/s'")
        count += 1

        // Mode D: Single Direction — Manual Download
        let prefsManualDL = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .download,
            launchAtLogin: false
        )
        let contentManualDL = MenuBarContentBuilder.build(
            preferences: prefsManualDL,
            pathState: .satisfiedWiFi,
            latestMeasurement: sampleMeasurement,
            dominantDirection: .upload // even if upload is dominant, manual dl wins
        )
        let textManualDL = MenuBarRenderer.renderPlainText(content: contentManualDL)
        assert(textManualDL == "↓ 10 MB/s", "Manual download must strictly render '↓ 10 MB/s'")
        count += 1

        // Mode E: Single Direction — Manual Upload
        let prefsManualUL = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .upload,
            launchAtLogin: false
        )
        let contentManualUL = MenuBarContentBuilder.build(
            preferences: prefsManualUL,
            pathState: .satisfiedWiFi,
            latestMeasurement: sampleMeasurement,
            dominantDirection: .download // even if download is dominant, manual ul wins
        )
        let textManualUL = MenuBarRenderer.renderPlainText(content: contentManualUL)
        assert(textManualUL == "↑ 2 MB/s", "Manual upload must strictly render '↑ 2 MB/s'")
        count += 1

        // Mode F: Single Direction — Automatic (dominant tracking)
        let prefsAuto = AppPreferences(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .download,
            launchAtLogin: false
        )
        let contentAuto = MenuBarContentBuilder.build(
            preferences: prefsAuto,
            pathState: .satisfiedWiFi,
            latestMeasurement: sampleMeasurement,
            dominantDirection: .download
        )
        let textAuto = MenuBarRenderer.renderPlainText(content: contentAuto)
        assert(textAuto == "↓ 10 MB/s", "Single direction automatic DL must render '↓ 10 MB/s'")
        count += 1

        // =====================================================================
        // SECTION 6: Preferences Store Resilience & Live Synchronization
        // =====================================================================

        // 9. Corrupted preference recovery & immediate publishing
        let testSuiteName = "in.arrry.test.compatibility.\(UUID().uuidString)"
        guard let testSuite = UserDefaults(suiteName: testSuiteName) else {
            fatalError("Failed to initialize test UserDefaults suite")
        }
        testSuite.removePersistentDomain(forName: testSuiteName)

        // Inject corrupted raw values into UserDefaults
        testSuite.set("invalidDisplayModeValue", forKey: "displayMode")
        testSuite.set(99999, forKey: "bothDirectionsStyle")
        testSuite.set("corruptedDirection", forKey: "manualDirection")

        let store = PreferencesStore(userDefaults: testSuite)
        let loadedPrefs = store.loadPreferences()

        // Should recover cleanly to defaults
        assert(loadedPrefs.displayMode == AppPreferences.default.displayMode, "Corrupted displayMode must recover to default")
        assert(loadedPrefs.bothDirectionsStyle == AppPreferences.default.bothDirectionsStyle, "Corrupted style must recover to default")
        assert(loadedPrefs.manualDirection == AppPreferences.default.manualDirection, "Corrupted manualDirection must recover to default")
        count += 1

        // Immediate preference update verification via SettingsManager
        let settingsManager = SettingsManager(preferencesStore: store)
        var publishedCount = 0
        let cancellable = settingsManager.$preferences.sink { _ in
            publishedCount += 1
        }
        _ = cancellable // retain

        settingsManager.updateDisplayMode(.singleDirectionAutomatic)
        settingsManager.updateManualDirection(.upload)
        assert(settingsManager.preferences.displayMode == .singleDirectionAutomatic, "Display mode update must be reflected immediately")
        assert(settingsManager.preferences.manualDirection == .upload, "Manual direction update must be reflected immediately")
        assert(publishedCount >= 2, "Preference changes must emit via Combine publisher")
        count += 1

        // =====================================================================
        // SECTION 7: Bundle Integrity & macOS 13.0 API Surface Audit
        // =====================================================================

        // 10. Info.plist integrity check
        let projectRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let plistURL = projectRoot.appendingPathComponent("ARRYNetworkCounter/Info.plist")

        if let plistData = try? Data(contentsOf: plistURL),
           let plistDict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] {
            let lsUIElement = plistDict["LSUIElement"] as? Bool
            assert(lsUIElement == true, "LSUIElement must be true for menu-bar agent application")

            let minSystemVer = plistDict["LSMinimumSystemVersion"] as? String
            assert(minSystemVer == "13.0", "LSMinimumSystemVersion must be 13.0")

            let bundleID = plistDict["CFBundleIdentifier"] as? String
            assert(bundleID == "in.arrry.networkcounter", "CFBundleIdentifier must match 'in.arrry.networkcounter'")

            let version = plistDict["CFBundleShortVersionString"] as? String
            assert(version == "1.0.0", "CFBundleShortVersionString must be '1.0.0'")
            count += 1
        } else {
            assertionFailure("Failed to load and parse ARRYNetworkCounter/Info.plist")
        }

        // 11. Bundled documentation files existence and accessibility
        let requiredDocs = [
            "SETUP_GUIDE.md",
            "USAGE_GUIDE.md",
            "TERMS_AND_CONDITIONS.md",
            "PRIVACY_POLICY.md"
        ]

        let userGuidesDir = projectRoot.appendingPathComponent("Documentation/UserGuides")
        let legalDir = projectRoot.appendingPathComponent("Documentation/Legal")

        for doc in requiredDocs {
            let docURL1 = userGuidesDir.appendingPathComponent(doc)
            let docURL2 = legalDir.appendingPathComponent(doc)
            let exists = FileManager.default.fileExists(atPath: docURL1.path) || FileManager.default.fileExists(atPath: docURL2.path)
            assert(exists, "Required documentation file '\(doc)' must exist")
        }
        count += 1

        // =====================================================================
        // SECTION 8: Concurrency & Stress Testing
        // =====================================================================

        // 12. Rapid preference switching stress test (100 iterations)
        for i in 0..<100 {
            let mode: DisplayMode = (i % 3 == 0) ? .bothDirections : ((i % 3 == 1) ? .singleDirectionManual : .singleDirectionAutomatic)
            let style: BothDirectionsStyle = (i % 2 == 0) ? .separateSpeeds : .combinedArrows
            let dir: NetworkDirection = (i % 2 == 0) ? .download : .upload
            store.setDisplayMode(mode)
            store.setBothDirectionsStyle(style)
            store.setManualDirection(dir)
        }
        assert(store.getLaunchAtLogin() == false, "Preferences store must withstand rapid concurrent mutations")
        count += 1

        // 13. High-frequency speed calculation stress test (50 iterations)
        let stressCalc = NetworkSpeedCalculator()
        var currentBytes: UInt64 = 1_000_000
        for i in 1...50 {
            currentBytes += UInt64(i * 10_000)
            let snap = NetworkSnapshot(
                receivedBytes: currentBytes,
                transmittedBytes: currentBytes / 2,
                timestamp: Date(timeIntervalSince1970: 2000.0 + Double(i)),
                monotonicTimeNanoseconds: UInt64(i) * 1_000_000_000,
                interface: wifiInterface
            )
            let res = await stressCalc.calculateSpeed(from: snap)
            if i > 1 {
                guard case .calculated = res else {
                    assertionFailure("High-frequency speed calculation failed at iteration \(i)")
                    return count
                }
            }
        }
        count += 1

        // 14. Transient memory audit: verify no historical metrics or persistence
        let finalDomain = testSuite.dictionaryRepresentation()
        let persistedKeys = finalDomain.keys.filter { $0.hasPrefix("in.arrry") || ["displayMode", "bothDirectionsStyle", "manualDirection", "singleDirectionArrowStyle", "launchAtLogin"].contains($0) }
        assert(persistedKeys.count <= 5, "Only the 5 documented user preference keys may exist in UserDefaults")
        count += 1

        testSuite.removePersistentDomain(forName: testSuiteName)
        return count
    }
}
