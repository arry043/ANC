import Foundation

/// Comprehensive unit test suite for `NetworkSpeedCalculator`.
public enum NetworkSpeedCalculatorTests {
    public static func run() async throws -> Int {
        var count = 0

        let wifiInterface = NetworkInterface(name: "en0", index: 1, type: .wifi, isUsable: true)
        let ethInterface = NetworkInterface(name: "en1", index: 2, type: .ethernet, isUsable: true)

        // MARK: - Group A: Basic Calculation Tests

        // Test 1: First sample establishes baseline
        let calc1 = NetworkSpeedCalculator()
        let snap1 = NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        )
        let res1 = await calc1.calculateSpeed(from: snap1)
        assert(res1 == .baselineEstablished, "First sample must establish baseline")
        let baseline1 = await calc1.baselineSnapshot
        assert(baseline1 == snap1, "Baseline must match first snapshot")
        count += 1

        // Test 2: Second sample calculates download speed correctly (1 second, 500 KB delta)
        let snap2 = NetworkSnapshot(
            receivedBytes: 1_500_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        )
        let res2 = await calc1.calculateSpeed(from: snap2)
        if case .calculated(let m) = res2 {
            assert(m.downloadBytesPerSecond == 500_000, "Download speed must be 500,000 B/s")
            assert(m.uploadBytesPerSecond == 0, "Upload speed must be 0 B/s")
            assert(m.elapsedSeconds == 1.0, "Elapsed seconds must be 1.0")
            assert(m.interface?.name == "en0", "Interface must be en0")
        } else {
            assertionFailure("Expected calculated speed measurement")
        }
        count += 1

        // Test 3: Third sample calculates upload speed correctly (1 second, 250 KB upload delta)
        let snap3 = NetworkSnapshot(
            receivedBytes: 1_500_000,
            transmittedBytes: 750_000,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifiInterface
        )
        let res3 = await calc1.calculateSpeed(from: snap3)
        if case .calculated(let m) = res3 {
            assert(m.downloadBytesPerSecond == 0, "Download speed must be 0 B/s")
            assert(m.uploadBytesPerSecond == 250_000, "Upload speed must be 250,000 B/s")
            assert(m.elapsedSeconds == 1.0, "Elapsed seconds must be 1.0")
        } else {
            assertionFailure("Expected calculated speed measurement")
        }
        count += 1

        // Test 4: Both directions calculate independently
        let calc4 = NetworkSpeedCalculator()
        _ = await calc4.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 2_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res4 = await calc4.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 12_000_000,
            transmittedBytes: 3_000_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        ))
        if case .calculated(let m) = res4 {
            assert(m.downloadBytesPerSecond == 2_000_000, "Download speed must be 2 MB/s")
            assert(m.uploadBytesPerSecond == 1_000_000, "Upload speed must be 1 MB/s")
            assert(m.isPositive, "Measurement must be positive")
        } else {
            assertionFailure("Expected calculated speed measurement")
        }
        count += 1

        // Test 5: No traffic produces genuine zero-speed measurement
        let res5 = await calc4.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 12_000_000,
            transmittedBytes: 3_000_000,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifiInterface
        ))
        if case .calculated(let m) = res5 {
            assert(m.downloadBytesPerSecond == 0, "Download speed must be 0")
            assert(m.uploadBytesPerSecond == 0, "Upload speed must be 0")
            assert(m.isZero, "Measurement must be zero")
            assert(m.download.isZero, "Download model must report isZero")
            assert(m.upload.isZero, "Upload model must report isZero")
        } else {
            assertionFailure("Expected genuine zero measurement")
        }
        count += 1

        // Test 6: Varied elapsed intervals (2.0 seconds)
        let calc6 = NetworkSpeedCalculator()
        _ = await calc6.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res6 = await calc6.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 2_000_000,
            transmittedBytes: 1_000_000,
            monotonicTimeNanoseconds: 3_000_000_000, // 2 seconds later
            interface: wifiInterface
        ))
        if case .calculated(let m) = res6 {
            assert(m.elapsedSeconds == 2.0, "Elapsed seconds must be 2.0")
            assert(m.downloadBytesPerSecond == 500_000, "1,000,000 / 2s = 500,000 B/s")
            assert(m.uploadBytesPerSecond == 250_000, "500,000 / 2s = 250,000 B/s")
        } else {
            assertionFailure("Expected calculated measurement for 2s interval")
        }
        count += 1

        // Test 7: Fractional elapsed seconds (0.5 seconds and 0.25 seconds)
        let calc7 = NetworkSpeedCalculator()
        _ = await calc7.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res7 = await calc7.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_100_000,
            transmittedBytes: 550_000,
            monotonicTimeNanoseconds: 1_500_000_000, // 0.5s later
            interface: wifiInterface
        ))
        if case .calculated(let m) = res7 {
            assert(m.elapsedSeconds == 0.5, "Elapsed seconds must be 0.5")
            assert(m.downloadBytesPerSecond == 200_000, "100,000 / 0.5s = 200,000 B/s")
            assert(m.uploadBytesPerSecond == 100_000, "50,000 / 0.5s = 100,000 B/s")
        } else {
            assertionFailure("Expected calculated measurement for 0.5s interval")
        }
        count += 1

        // MARK: - Group B: Timing Tests

        // Test 8: Irregular sampling interval (1.234 seconds)
        let calc8 = NetworkSpeedCalculator()
        _ = await calc8.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res8 = await calc8.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 11_234_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 2_234_000_000, // exactly 1.234s
            interface: wifiInterface
        ))
        if case .calculated(let m) = res8 {
            assert(abs(m.elapsedSeconds - 1.234) < 0.0001, "Elapsed seconds must be 1.234")
            assert(abs(m.downloadBytesPerSecond - 1_000_000) < 1.0, "1,234,000 / 1.234s = 1,000,000 B/s")
        } else {
            assertionFailure("Expected calculated measurement for irregular interval")
        }
        count += 1

        // Test 9: Zero elapsed nanoseconds rejected
        let calc9 = NetworkSpeedCalculator()
        let snap9a = NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 5_000_000_000,
            interface: wifiInterface
        )
        _ = await calc9.calculateSpeed(from: snap9a)
        let snap9b = NetworkSnapshot(
            receivedBytes: 1_100_000,
            transmittedBytes: 550_000,
            monotonicTimeNanoseconds: 5_000_000_000, // same timestamp!
            interface: wifiInterface
        )
        let res9 = await calc9.calculateSpeed(from: snap9b)
        assert(res9 == .sampleRejected(reason: .zeroElapsedNanoseconds), "Zero elapsed time must be rejected")
        count += 1

        // Test 10: Reversed timestamp rejected
        let snap9c = NetworkSnapshot(
            receivedBytes: 1_100_000,
            transmittedBytes: 550_000,
            monotonicTimeNanoseconds: 4_999_999_999, // earlier timestamp!
            interface: wifiInterface
        )
        let res10 = await calc9.calculateSpeed(from: snap9c)
        assert(res10 == .sampleRejected(reason: .reversedTimestamp), "Reversed timestamp must be rejected")
        count += 1

        // Test 11: Preserved baseline after sample rejection
        // Subsequent sample 1 second after snap9a must compute speed against snap9a baseline
        let snap9d = NetworkSnapshot(
            receivedBytes: 1_200_000,
            transmittedBytes: 600_000,
            monotonicTimeNanoseconds: 6_000_000_000, // 1s after snap9a
            interface: wifiInterface
        )
        let res11 = await calc9.calculateSpeed(from: snap9d)
        if case .calculated(let m) = res11 {
            assert(m.elapsedSeconds == 1.0, "Elapsed seconds must be 1.0 against preserved baseline")
            assert(m.downloadBytesPerSecond == 200_000, "200,000 B delta over 1.0s")
            assert(m.uploadBytesPerSecond == 100_000, "100,000 B delta over 1.0s")
        } else {
            assertionFailure("Expected calculated measurement using preserved baseline")
        }
        count += 1

        // Test 12: Extremely small valid interval (1 microsecond = 1000 ns)
        let calc12 = NetworkSpeedCalculator()
        _ = await calc12.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000,
            transmittedBytes: 1_000,
            monotonicTimeNanoseconds: 1_000_000,
            interface: wifiInterface
        ))
        let res12 = await calc12.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_010, // 10 bytes transferred
            transmittedBytes: 1_005, // 5 bytes transferred
            monotonicTimeNanoseconds: 1_001_000, // 1,000 ns = 0.000001s
            interface: wifiInterface
        ))
        if case .calculated(let m) = res12 {
            assert(m.elapsedSeconds == 0.000001, "Elapsed seconds must be 1e-6")
            assert(abs(m.downloadBytesPerSecond - 10_000_000) < 1.0, "10 B / 1us = 10 MB/s")
            assert(abs(m.uploadBytesPerSecond - 5_000_000) < 1.0, "5 B / 1us = 5 MB/s")
        } else {
            assertionFailure("Expected calculation for small interval")
        }
        count += 1

        // MARK: - Group C: Counter Tests

        // Test 13: Received counter decreases triggers baseline reset
        let calc13 = NetworkSpeedCalculator()
        _ = await calc13.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res13 = await calc13.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 9_999_999, // decreased!
            transmittedBytes: 5_500_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        ))
        assert(res13 == .baselineReset(reason: .counterDecreased), "Decreased received counter must reset baseline")
        count += 1

        // Test 14: Transmitted counter decreases triggers baseline reset
        let calc14 = NetworkSpeedCalculator()
        _ = await calc14.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res14 = await calc14.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_500_000,
            transmittedBytes: 4_999_999, // decreased!
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        ))
        assert(res14 == .baselineReset(reason: .counterDecreased), "Decreased transmitted counter must reset baseline")
        count += 1

        // Test 15: Both counters reset to zero triggers baseline reset
        let res15 = await calc14.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 0,
            transmittedBytes: 0,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: wifiInterface
        ))
        assert(res15 == .baselineReset(reason: .counterDecreased), "Reset to zero must trigger baseline reset")
        count += 1

        // Test 16: Safe calculation following a counter decrease reset
        let res16 = await calc14.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 100_000,
            transmittedBytes: 50_000,
            monotonicTimeNanoseconds: 4_000_000_000, // 1s after reset to (0, 0)
            interface: wifiInterface
        ))
        if case .calculated(let m) = res16 {
            assert(m.downloadBytesPerSecond == 100_000, "100,000 delta after baseline reset")
            assert(m.uploadBytesPerSecond == 50_000, "50,000 delta after baseline reset")
        } else {
            assertionFailure("Expected speed calculation after baseline reset")
        }
        count += 1

        // Test 17: Large counter values (1 TB = 1,000,000,000,000 bytes)
        let calc17 = NetworkSpeedCalculator()
        _ = await calc17.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000_000_000,
            transmittedBytes: 500_000_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res17 = await calc17.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_010_000_000, // +10 MB
            transmittedBytes: 500_005_000_000, // +5 MB
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: wifiInterface
        ))
        if case .calculated(let m) = res17 {
            assert(m.downloadBytesPerSecond == 10_000_000, "10 MB/s for large counters")
            assert(m.uploadBytesPerSecond == 5_000_000, "5 MB/s for large counters")
        } else {
            assertionFailure("Expected speed calculation for large counters")
        }
        count += 1

        // MARK: - Group D: Interface Transition Tests

        // Test 18: Interface transition resets baseline
        let calc18 = NetworkSpeedCalculator()
        _ = await calc18.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 10_000_000,
            transmittedBytes: 5_000_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        let res18 = await calc18.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 200_000, // different interface has different counters!
            transmittedBytes: 100_000,
            monotonicTimeNanoseconds: 2_000_000_000,
            interface: ethInterface // changed to en1!
        ))
        assert(res18 == .baselineReset(reason: .interfaceChanged), "Interface transition must reset baseline")
        count += 1

        // Test 19: Subsequent sample on new interface calculates cleanly without spikes
        let res19 = await calc18.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 300_000,
            transmittedBytes: 150_000,
            monotonicTimeNanoseconds: 3_000_000_000,
            interface: ethInterface
        ))
        if case .calculated(let m) = res19 {
            assert(m.downloadBytesPerSecond == 100_000, "100,000 B/s on new interface")
            assert(m.uploadBytesPerSecond == 50_000, "50,000 B/s on new interface")
            assert(m.interface?.name == "en1", "Interface must be en1")
        } else {
            assertionFailure("Expected clean speed calculation on new interface")
        }
        count += 1

        // Test 20: Interface disappears (becomes nil)
        let res20 = await calc18.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 350_000,
            transmittedBytes: 175_000,
            monotonicTimeNanoseconds: 4_000_000_000,
            interface: nil
        ))
        assert(res20 == .baselineReset(reason: .interfaceChanged), "Interface becoming nil must reset baseline")
        count += 1

        // MARK: - Group E: Lifecycle & Connectivity Tests

        // Test 21: reset() clears baseline
        let calc21 = NetworkSpeedCalculator()
        _ = await calc21.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 1_000_000,
            transmittedBytes: 500_000,
            monotonicTimeNanoseconds: 1_000_000_000,
            interface: wifiInterface
        ))
        await calc21.reset()
        let baseline21 = await calc21.baselineSnapshot
        assert(baseline21 == nil, "reset() must clear baseline to nil")
        count += 1

        // Test 22: Sample after reset establishes fresh baseline
        let res22 = await calc21.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 5_000_000,
            transmittedBytes: 2_000_000,
            monotonicTimeNanoseconds: 10_000_000_000, // long disconnected gap
            interface: wifiInterface
        ))
        assert(res22 == .baselineEstablished, "Sample after reset must establish fresh baseline")
        count += 1

        // Test 23: Subsequent sample resumes speed calculation
        let res23 = await calc21.calculateSpeed(from: NetworkSnapshot(
            receivedBytes: 5_100_000,
            transmittedBytes: 2_050_000,
            monotonicTimeNanoseconds: 11_000_000_000,
            interface: wifiInterface
        ))
        if case .calculated(let m) = res23 {
            assert(m.downloadBytesPerSecond == 100_000, "100,000 B/s after reconnection")
            assert(m.uploadBytesPerSecond == 50_000, "50,000 B/s after reconnection")
        } else {
            assertionFailure("Expected speed calculation after reconnection baseline")
        }
        count += 1

        return count
    }
}
