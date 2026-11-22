import Foundation

/// Unit test suite for `MenuBarContentBuilder` display mode business logic.
public enum MenuBarContentBuilderTests {
    private static func makeMeasurement(downloadBps: Double, uploadBps: Double) -> SpeedMeasurement {
        SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: downloadBps),
            upload: NetworkSpeed(bytesPerSecond: uploadBps),
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 1_000_000_000
        )
    }

    public static func run() throws -> Int {
        var count = 0

        let m1 = makeMeasurement(downloadBps: 2_450_000, uploadBps: 120_000)

        // Test 1: Both directions separate speeds - connected with active throughput
        let prefs1 = AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .separateSpeeds,
            manualDirection: .download,
            launchAtLogin: false
        )
        let c1 = MenuBarContentBuilder.build(
            preferences: prefs1,
            pathState: .satisfiedWiFi,
            latestMeasurement: m1,
            dominantDirection: .download
        )
        assert(c1.displayMode == .bothDirections, "Mode must be bothDirections")
        assert(c1.bothDirectionsStyle == .separateSpeeds, "Style must be separateSpeeds")
        assert(c1.downloadSpeedText == "2.45 MB/s", "DL text must be 2.45 MB/s")
        assert(c1.uploadSpeedText == "120 KB/s", "UL text must be 120 KB/s")
        assert(c1.isConnected, "Must be connected")
        assert(!c1.isIdle, "Must not be idle")
        assert(c1.singleDisplayedSpeedText == nil, "Separate speeds mode has no single speed text")
        count += 1

        // Test 2: Both directions separate speeds - idle / zero traffic
        let mIdle = makeMeasurement(downloadBps: 0, uploadBps: 0)
        let c2 = MenuBarContentBuilder.build(
            preferences: prefs1,
            pathState: .satisfiedWiFi,
            latestMeasurement: mIdle,
            dominantDirection: .download
        )
        assert(c2.downloadSpeedText == "0 KB/s", "Idle DL text must be 0 KB/s")
        assert(c2.uploadSpeedText == "0 KB/s", "Idle UL text must be 0 KB/s")
        assert(c2.isIdle, "Must be marked idle")
        count += 1

        // Test 3: Both directions separate speeds - disconnected path
        let c3 = MenuBarContentBuilder.build(
            preferences: prefs1,
            pathState: .unsatisfied,
            latestMeasurement: m1, // Stale measurement must be ignored when unsatisfied
            dominantDirection: .download
        )
        assert(c3.downloadSpeedText == "0 KB/s", "Disconnected DL must be 0 KB/s")
        assert(c3.uploadSpeedText == "0 KB/s", "Disconnected UL must be 0 KB/s")
        assert(!c3.isConnected, "Must not be connected")
        assert(c3.isIdle, "Must be idle when disconnected")
        count += 1

        // Test 4: Both directions combined arrows - download dominant
        let prefs2 = AppPreferences(
            displayMode: .bothDirections,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        let c4 = MenuBarContentBuilder.build(
            preferences: prefs2,
            pathState: .satisfiedEthernet,
            latestMeasurement: m1,
            dominantDirection: .download
        )
        assert(c4.bothDirectionsStyle == .combinedArrows, "Style must be combinedArrows")
        assert(c4.dominantDirection == .download, "Dominant direction must be download")
        assert(c4.singleDisplayedSpeedText == "2.45 MB/s", "Single speed text must match dominant download")
        count += 1

        // Test 5: Both directions combined arrows - upload dominant
        let mUpload = makeMeasurement(downloadBps: 50_000, uploadBps: 1_800_000)
        let c5 = MenuBarContentBuilder.build(
            preferences: prefs2,
            pathState: .satisfiedEthernet,
            latestMeasurement: mUpload,
            dominantDirection: .upload
        )
        assert(c5.dominantDirection == .upload, "Dominant direction must be upload")
        assert(c5.singleDisplayedSpeedText == "1.8 MB/s", "Single speed text must match dominant upload")
        count += 1

        // Test 6: Single direction manual - download selected (ignores upload dominance)
        let prefsManualDL = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        let c6 = MenuBarContentBuilder.build(
            preferences: prefsManualDL,
            pathState: .satisfiedWiFi,
            latestMeasurement: mUpload, // Heavy upload, light download
            dominantDirection: .upload
        )
        assert(c6.displayMode == .singleDirectionManual, "Mode must be singleDirectionManual")
        assert(c6.manualDirection == .download, "Manual direction must be download")
        assert(c6.singleDisplayedSpeedText == "50 KB/s", "Manual download must strictly show download speed")
        count += 1

        // Test 7: Single direction manual - upload selected (ignores download dominance)
        let prefsManualUL = AppPreferences(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: false
        )
        let c7 = MenuBarContentBuilder.build(
            preferences: prefsManualUL,
            pathState: .satisfiedWiFi,
            latestMeasurement: m1, // Heavy download, light upload
            dominantDirection: .download
        )
        assert(c7.manualDirection == .upload, "Manual direction must be upload")
        assert(c7.singleDisplayedSpeedText == "120 KB/s", "Manual upload must strictly show upload speed")
        count += 1

        // Test 8: Single direction automatic - download dominant
        let prefsAuto = AppPreferences(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .download,
            launchAtLogin: false
        )
        let c8 = MenuBarContentBuilder.build(
            preferences: prefsAuto,
            pathState: .satisfiedWiFi,
            latestMeasurement: m1,
            dominantDirection: .download
        )
        assert(c8.displayMode == .singleDirectionAutomatic, "Mode must be singleDirectionAutomatic")
        assert(c8.dominantDirection == .download, "Dominant direction must be download")
        assert(c8.singleDisplayedSpeedText == "2.45 MB/s", "Auto DL speed must be 2.45 MB/s")
        count += 1

        // Test 9: Single direction automatic - upload dominant
        let c9 = MenuBarContentBuilder.build(
            preferences: prefsAuto,
            pathState: .satisfiedWiFi,
            latestMeasurement: mUpload,
            dominantDirection: .upload
        )
        assert(c9.dominantDirection == .upload, "Dominant direction must be upload")
        assert(c9.singleDisplayedSpeedText == "1.8 MB/s", "Auto UL speed must be 1.8 MB/s")
        count += 1

        // Test 10: Single direction automatic - idle fallback
        let c10 = MenuBarContentBuilder.build(
            preferences: prefsAuto,
            pathState: .satisfiedWiFi,
            latestMeasurement: mIdle,
            dominantDirection: .download
        )
        assert(c10.dominantDirection == .download, "Idle auto dominant direction must be download")
        assert(c10.singleDisplayedSpeedText == "0 KB/s", "Idle auto speed text must be 0 KB/s")
        assert(c10.isIdle, "Must be idle")
        count += 1

        return count
    }
}
