import Foundation

/// Unit test suite for `DominantDirectionEngine`, `DirectionDecision`, and `DirectionSwitchingConfiguration`.
public enum DominantDirectionEngineTests {
    private static func makeMeasurement(downloadBps: Double, uploadBps: Double) -> SpeedMeasurement {
        SpeedMeasurement(
            download: NetworkSpeed(bytesPerSecond: downloadBps),
            upload: NetworkSpeed(bytesPerSecond: uploadBps),
            elapsedSeconds: 1.0,
            monotonicTimeNanoseconds: 1_000_000_000
        )
    }

    public static func run() async throws -> Int {
        var count = 0

        // Test 1: Initial state and default configuration
        let engine = DominantDirectionEngine()
        let initialDir = await engine.currentDirection
        let initialCandidate = await engine.pendingCandidate
        let initialCandidateCount = await engine.consecutiveCandidateCount
        let config = await engine.configuration

        assert(initialDir == .download, "Initial direction must be .download")
        assert(initialCandidate == nil, "Initial pending candidate must be nil")
        assert(initialCandidateCount == 0, "Initial candidate count must be 0")
        assert(config.relativeMargin == 0.10, "Default relative margin must be 10%")
        assert(config.absoluteThresholdBytesPerSecond == 10_000.0, "Default noise floor must be 10,000 B/s")
        assert(config.requiredConsecutiveSamples == 2, "Default consecutive sample confirmation must be 2")
        assert(config.defaultDirection == .download, "Default direction must be .download")
        count += 1

        // Test 2: Initial evaluation with download dominance remains download without switching
        let d1 = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 10_000))
        assert(d1.direction == .download, "Direction should be download")
        assert(!d1.didSwitch, "didSwitch should be false")
        assert(d1.candidateDirection == nil, "candidateDirection should be nil")
        assert(d1.confirmationCount == 0, "confirmationCount should be 0")
        count += 1

        // Test 3: Relative margin hysteresis: +5% upload does NOT qualify as candidate
        // DL: 100,000, UL: 105,000 (+5% exceeds current, but < 10% relative margin)
        let d2 = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 105_000))
        assert(d2.direction == .download, "Direction should remain download")
        assert(!d2.didSwitch, "didSwitch should be false")
        assert(d2.candidateDirection == nil, "Candidate should not qualify below 10% margin")
        assert(d2.confirmationCount == 0, "Confirmation count should be 0")
        let candidateAfterSubMargin = await engine.pendingCandidate
        assert(candidateAfterSubMargin == nil, "Engine pendingCandidate should be nil")
        count += 1

        // Test 4: Absolute threshold noise floor: +400% relative but diff < 10,000 B/s does NOT qualify
        // DL: 1,000, UL: 5,000 (diff: 4,000 B/s < 10,000 B/s)
        let d3 = await engine.evaluate(makeMeasurement(downloadBps: 1_000, uploadBps: 5_000))
        assert(d3.direction == .download, "Direction should remain download on sub-threshold noise")
        assert(!d3.didSwitch, "didSwitch should be false")
        assert(d3.candidateDirection == nil, "Candidate should not qualify when difference < noise floor")
        assert(d3.confirmationCount == 0, "Confirmation count should be 0")
        count += 1

        // Test 5: Exact boundary qualification: UL exceeds DL by exactly 10% AND exactly 10,000 B/s
        // DL: 100,000, UL: 110,000 (diff: 10,000 B/s, relative: 1.10x)
        let d4 = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 110_000))
        assert(d4.direction == .download, "First qualifying sample should not switch yet")
        assert(!d4.didSwitch, "didSwitch should be false on sample 1")
        assert(d4.candidateDirection == .upload, "Candidate direction should be upload")
        assert(d4.confirmationCount == 1, "Confirmation count should be 1")
        let pendingCandidate = await engine.pendingCandidate
        let pendingCount = await engine.consecutiveCandidateCount
        assert(pendingCandidate == .upload, "Pending candidate should be stored")
        assert(pendingCount == 1, "Pending count should be 1")
        count += 1

        // Test 6: Consecutive confirmation requirement: second qualifying sample switches direction
        // DL: 100,000, UL: 150,000
        let d5 = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 150_000))
        assert(d5.direction == .upload, "Second consecutive sample must switch direction to upload")
        assert(d5.didSwitch, "didSwitch should be true")
        assert(d5.candidateDirection == nil, "candidateDirection should be cleared on switch")
        assert(d5.confirmationCount == 0, "confirmationCount should be 0 on switch")
        let currentAfterSwitch = await engine.currentDirection
        assert(currentAfterSwitch == .upload, "Engine currentDirection should now be .upload")
        count += 1

        // Test 7: Interruption / transient spike test: streak is reset if a sample does not qualify
        // Switch back to download first
        _ = await engine.evaluate(makeMeasurement(downloadBps: 200_000, uploadBps: 50_000))
        _ = await engine.evaluate(makeMeasurement(downloadBps: 200_000, uploadBps: 50_000))
        let dirBeforeInterruption = await engine.currentDirection
        assert(dirBeforeInterruption == .download, "Engine should be in download direction")

        // Sample 1: qualifying upload spike
        let spike1 = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 200_000))
        assert(spike1.direction == .download, "Still download after 1st spike")
        assert(spike1.candidateDirection == .upload, "Candidate is upload")
        assert(spike1.confirmationCount == 1, "Count is 1")

        // Sample 2: download traffic recovers, upload drop below qualification
        let recovered = await engine.evaluate(makeMeasurement(downloadBps: 150_000, uploadBps: 100_000))
        assert(recovered.direction == .download, "Remains download")
        assert(!recovered.didSwitch, "No switch")
        assert(recovered.candidateDirection == nil, "Pending candidate must be cleared")
        assert(recovered.confirmationCount == 0, "Confirmation count must be reset to 0")

        // Sample 3: upload spike reappears -> count starts over at 1, does NOT switch!
        let spike2 = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 200_000))
        assert(spike2.direction == .download, "Must not switch because streak was broken")
        assert(!spike2.didSwitch, "didSwitch must be false")
        assert(spike2.candidateDirection == .upload, "Candidate is upload again")
        assert(spike2.confirmationCount == 1, "Count is 1")
        count += 1

        // Test 8: Switching back from Upload to Download requires 2 consecutive samples
        // First confirm switch to upload with a second spike
        let switchUpload = await engine.evaluate(makeMeasurement(downloadBps: 100_000, uploadBps: 200_000))
        assert(switchUpload.direction == .upload && switchUpload.didSwitch, "Switched to upload")

        // Now download leads: DL 250k, UL 100k (+150% DL, diff 150k >= 10k)
        let dlSample1 = await engine.evaluate(makeMeasurement(downloadBps: 250_000, uploadBps: 100_000))
        assert(dlSample1.direction == .upload, "Sample 1: direction remains upload")
        assert(!dlSample1.didSwitch, "Sample 1: didSwitch is false")
        assert(dlSample1.candidateDirection == .download, "Sample 1: candidate is download")
        assert(dlSample1.confirmationCount == 1, "Sample 1: count is 1")

        let dlSample2 = await engine.evaluate(makeMeasurement(downloadBps: 250_000, uploadBps: 100_000))
        assert(dlSample2.direction == .download, "Sample 2: switches to download")
        assert(dlSample2.didSwitch, "Sample 2: didSwitch is true")
        assert(dlSample2.candidateDirection == nil, "Sample 2: candidate cleared")
        count += 1

        // Test 9: Idle traffic behavior (DL: 0, UL: 0)
        // From download: idle keeps download and didSwitch is false
        let idleDl = await engine.evaluate(makeMeasurement(downloadBps: 0, uploadBps: 0))
        assert(idleDl.direction == .download, "Idle from download remains download")
        assert(!idleDl.didSwitch, "Idle from download does not report switch")

        // Switch to upload
        _ = await engine.evaluate(makeMeasurement(downloadBps: 50_000, uploadBps: 150_000))
        _ = await engine.evaluate(makeMeasurement(downloadBps: 50_000, uploadBps: 150_000))
        let dirBeforeIdle = await engine.currentDirection
        assert(dirBeforeIdle == .upload, "Should be upload")

        // Idle from upload immediately reverts to download and reports didSwitch = true
        let idleUl = await engine.evaluate(makeMeasurement(downloadBps: 0, uploadBps: 0))
        assert(idleUl.direction == .download, "Idle from upload reverts to download")
        assert(idleUl.didSwitch, "Idle from upload reports didSwitch = true")
        assert(idleUl.candidateDirection == nil, "Candidate is cleared")
        assert(idleUl.confirmationCount == 0, "Count is 0")
        count += 1

        // Test 10: Near-equal oscillation stability
        // Traffic fluctuating around 50k (DL 50k/UL 52k, then DL 52k/UL 50k) does not flip
        let osc1 = await engine.evaluate(makeMeasurement(downloadBps: 50_000, uploadBps: 52_000))
        let osc2 = await engine.evaluate(makeMeasurement(downloadBps: 52_000, uploadBps: 50_000))
        let osc3 = await engine.evaluate(makeMeasurement(downloadBps: 50_000, uploadBps: 52_000))
        assert(osc1.direction == .download && !osc1.didSwitch && osc1.candidateDirection == nil, "Osc 1 stable")
        assert(osc2.direction == .download && !osc2.didSwitch && osc2.candidateDirection == nil, "Osc 2 stable")
        assert(osc3.direction == .download && !osc3.didSwitch && osc3.candidateDirection == nil, "Osc 3 stable")
        count += 1

        // Test 11: reset() restores default direction and clears state
        _ = await engine.evaluate(makeMeasurement(downloadBps: 50_000, uploadBps: 150_000))
        _ = await engine.evaluate(makeMeasurement(downloadBps: 50_000, uploadBps: 150_000))
        let dirBeforeReset = await engine.currentDirection
        assert(dirBeforeReset == .upload, "Must be upload prior to reset")
        await engine.reset()
        let dirAfterReset = await engine.currentDirection
        let candAfterReset = await engine.pendingCandidate
        let countAfterReset = await engine.consecutiveCandidateCount
        assert(dirAfterReset == .download, "Direction reset to download")
        assert(candAfterReset == nil, "Candidate reset to nil")
        assert(countAfterReset == 0, "Count reset to 0")
        count += 1

        // Test 12: Custom configuration injection
        let customConfig = DirectionSwitchingConfiguration(
            relativeMargin: 0.25, // 25% margin
            absoluteThresholdBytesPerSecond: 50_000.0, // 50 KB/s noise floor
            requiredConsecutiveSamples: 3, // 3 samples
            defaultDirection: .upload // default upload
        )
        let customEngine = DominantDirectionEngine(configuration: customConfig)
        let customInitialDir = await customEngine.currentDirection
        assert(customInitialDir == .upload, "Custom default direction is upload")

        // Opposite is download: DL 120k, UL 100k (+20% relative < 25%, diff 20k < 50k) -> does NOT qualify
        let cd1 = await customEngine.evaluate(makeMeasurement(downloadBps: 120_000, uploadBps: 100_000))
        assert(cd1.direction == .upload && cd1.candidateDirection == nil, "Custom sub-margin does not qualify")

        // DL 200k, UL 100k (+100% relative >= 25%, diff 100k >= 50k) -> qualifies
        let cd2 = await customEngine.evaluate(makeMeasurement(downloadBps: 200_000, uploadBps: 100_000))
        assert(cd2.direction == .upload && cd2.confirmationCount == 1, "Custom sample 1")
        let cd3 = await customEngine.evaluate(makeMeasurement(downloadBps: 200_000, uploadBps: 100_000))
        assert(cd3.direction == .upload && cd3.confirmationCount == 2, "Custom sample 2")
        let cd4 = await customEngine.evaluate(makeMeasurement(downloadBps: 200_000, uploadBps: 100_000))
        assert(cd4.direction == .download && cd4.didSwitch, "Custom sample 3 switches")
        count += 1

        return count
    }
}
