import Foundation

/// Unit test suite for `ByteFormatter` and `SpeedFormatter`.
public enum SpeedFormatterTests {
    public static func run() throws -> Int {
        var count = 0
        let formatter = SpeedFormatter.shared
        let byteFormatter = ByteFormatter.shared

        // MARK: - Group A: Unit Conversion & Base-1000 Scaling
        assert(SpeedUnit.bytesPerSecond.scale == 1.0, "B/s scale must be 1")
        assert(SpeedUnit.kilobytesPerSecond.scale == 1_000.0, "KB/s scale must be 1,000")
        assert(SpeedUnit.megabytesPerSecond.scale == 1_000_000.0, "MB/s scale must be 1,000,000")
        assert(SpeedUnit.gigabytesPerSecond.scale == 1_000_000_000.0, "GB/s scale must be 1,000,000,000")
        assert(SpeedUnit.terabytesPerSecond.scale == 1_000_000_000_000.0, "TB/s scale must be 1,000,000,000,000")
        count += 1

        // Test 1: B/s conversion
        assert(formatter.format(bytesPerSecond: 500) == "500 B/s", "500 B/s conversion failed")
        count += 1

        // Test 2: KB/s conversion (base 1000)
        assert(formatter.format(bytesPerSecond: 1_000) == "1 KB/s", "1,000 B/s must equal 1 KB/s")
        assert(formatter.format(bytesPerSecond: 1_500) == "1.5 KB/s", "1,500 B/s must equal 1.5 KB/s")
        count += 1

        // Test 3: MB/s conversion (base 1000)
        assert(formatter.format(bytesPerSecond: 1_000_000) == "1 MB/s", "1,000,000 B/s must equal 1 MB/s")
        assert(formatter.format(bytesPerSecond: 2_450_000) == "2.45 MB/s", "2,450,000 B/s must equal 2.45 MB/s")
        count += 1

        // Test 4: GB/s conversion (base 1000)
        assert(formatter.format(bytesPerSecond: 1_000_000_000) == "1 GB/s", "1,000,000,000 B/s must equal 1 GB/s")
        assert(formatter.format(bytesPerSecond: 1_250_000_000) == "1.25 GB/s", "1,250,000,000 B/s must equal 1.25 GB/s")
        count += 1

        // Test 5: TB/s conversion (base 1000)
        assert(formatter.format(bytesPerSecond: 1_000_000_000_000) == "1 TB/s", "1,000,000,000,000 B/s must equal 1 TB/s")
        assert(formatter.format(bytesPerSecond: 1_200_000_000_000) == "1.2 TB/s", "1,200,000,000,000 B/s must equal 1.2 TB/s")
        count += 1

        // MARK: - Group B: Automatic Unit Selection & Boundaries

        // Test 6: B/s to KB/s boundary
        assert(formatter.format(bytesPerSecond: 999) == "999 B/s", "999 B/s must be in B/s")
        assert(formatter.format(bytesPerSecond: 1_000) == "1 KB/s", "1000 B/s must be in KB/s")
        assert(formatter.format(bytesPerSecond: 1_001) == "1 KB/s", "1001 B/s must be in KB/s")
        count += 1

        // Test 7: KB/s to MB/s boundary
        assert(formatter.format(bytesPerSecond: 999_999) == "1000 KB/s", "999,999 B/s must format as 1000 KB/s per ADR-034")
        assert(formatter.format(bytesPerSecond: 1_000_000) == "1 MB/s", "1,000,000 B/s must be in MB/s")
        assert(formatter.format(bytesPerSecond: 1_000_001) == "1 MB/s", "1,000,001 B/s must be in MB/s")
        count += 1

        // Test 8: MB/s to GB/s boundary
        assert(formatter.format(bytesPerSecond: 999_999_999) == "1000 MB/s", "999,999,999 B/s must format as 1000 MB/s per ADR-034")
        assert(formatter.format(bytesPerSecond: 1_000_000_000) == "1 GB/s", "1,000,000,000 B/s must be in GB/s")
        count += 1

        // Test 9: GB/s to TB/s boundary
        assert(formatter.format(bytesPerSecond: 999_999_999_999) == "1000 GB/s", "999,999,999,999 B/s must format as 1000 GB/s per ADR-034")
        assert(formatter.format(bytesPerSecond: 1_000_000_000_000) == "1 TB/s", "1,000,000,000,000 B/s must be in TB/s")
        count += 1

        // MARK: - Group C: Decimal Precision & Trailing Zeros

        // Test 10: Whole number values remove trailing decimal zeros
        assert(formatter.format(bytesPerSecond: 10_000) == "10 KB/s", "10.00 KB/s must strip to 10 KB/s")
        assert(formatter.format(bytesPerSecond: 50_000_000) == "50 MB/s", "50.00 MB/s must strip to 50 MB/s")
        assert(formatter.format(bytesPerSecond: 2_000_000_000) == "2 GB/s", "2.00 GB/s must strip to 2 GB/s")
        count += 1

        // Test 11: One decimal place values preserve tenths, strip hundredths zero
        assert(formatter.format(bytesPerSecond: 1_100) == "1.1 KB/s", "1.10 KB/s must strip to 1.1 KB/s")
        assert(formatter.format(bytesPerSecond: 2_500_000) == "2.5 MB/s", "2.50 MB/s must strip to 2.5 MB/s")
        count += 1

        // Test 12: Two decimal places values preserved
        assert(formatter.format(bytesPerSecond: 450_250) == "450.25 KB/s", "450,250 must format as 450.25 KB/s")
        assert(formatter.format(bytesPerSecond: 12_340_000) == "12.34 MB/s", "12,340,000 must format as 12.34 MB/s")
        count += 1

        // Test 13: Rounding beyond 2 decimal places
        assert(formatter.format(bytesPerSecond: 123_456) == "123.46 KB/s", "123,456 must round to 123.46 KB/s")
        assert(formatter.format(bytesPerSecond: 123_454) == "123.45 KB/s", "123,454 must round to 123.45 KB/s")
        count += 1

        // MARK: - Group D: Zero and Small Values

        // Test 14: Zero speed requirement — strictly 0 KB/s
        assert(formatter.format(NetworkSpeed.zero) == "0 KB/s", "NetworkSpeed.zero must format as 0 KB/s")
        assert(formatter.format(bytesPerSecond: 0.0) == "0 KB/s", "0.0 B/s must format as 0 KB/s")
        assert(formatter.format(bytesPerSecond: -0.0) == "0 KB/s", "-0.0 B/s must format as 0 KB/s")
        let zeroDetails = formatter.formatDetails(bytesPerSecond: 0.0)
        assert(zeroDetails.unit == .kilobytesPerSecond, "Zero speed unit must be KB/s")
        assert(zeroDetails.formattedValue == "0", "Zero speed value must be '0'")
        count += 1

        // Test 15: Small integer B/s values
        assert(formatter.format(bytesPerSecond: 1) == "1 B/s", "1 B/s failed")
        assert(formatter.format(bytesPerSecond: 10) == "10 B/s", "10 B/s failed")
        assert(formatter.format(bytesPerSecond: 42) == "42 B/s", "42 B/s failed")
        count += 1

        // Test 16: Fractional small positive B/s values
        assert(formatter.format(bytesPerSecond: 0.4) == "1 B/s", "Fractional B/s below 0.5 clamps to readable 1 B/s")
        assert(formatter.format(bytesPerSecond: 0.8) == "1 B/s", "Fractional B/s rounds to 1 B/s")
        count += 1

        // MARK: - Group E: Large & Invalid Values

        // Test 17: Values exceeding TB/s scale continue in TB/s
        assert(formatter.format(bytesPerSecond: 10_000_000_000_000) == "10 TB/s", "10 TB/s failed")
        assert(formatter.format(bytesPerSecond: 500_000_000_000_000) == "500 TB/s", "500 TB/s failed")
        count += 1

        // Test 18: Negative speeds fallback safely to 0 KB/s
        assert(formatter.format(bytesPerSecond: -100.0) == "0 KB/s", "Negative speed must format as 0 KB/s")
        assert(formatter.format(bytesPerSecond: -1_000_000.0) == "0 KB/s", "Negative MB/s must format as 0 KB/s")
        count += 1

        // Test 19: Non-finite values fallback safely to 0 KB/s
        assert(formatter.format(bytesPerSecond: Double.nan) == "0 KB/s", "NaN must format as 0 KB/s")
        assert(formatter.format(bytesPerSecond: Double.infinity) == "0 KB/s", "+Infinity must format as 0 KB/s")
        assert(formatter.format(bytesPerSecond: -Double.infinity) == "0 KB/s", "-Infinity must format as 0 KB/s")
        count += 1

        // MARK: - Group F: Determinism and Locale Independence

        // Test 20: Deterministic decimal separator (always '.')
        let detail = byteFormatter.format(bytesPerSecond: 1_500)
        assert(detail.formattedValue.contains("."), "Decimal value must contain '.'")
        assert(!detail.formattedValue.contains(","), "Decimal value must never contain ','")
        assert(detail.displayString == "1.5 KB/s", "Display string must match exact POSIX output")
        count += 1

        // Test 21: No thousands separators in output
        let largeKB = formatter.format(bytesPerSecond: 450_250)
        assert(largeKB == "450.25 KB/s", "Must not contain comma thousands separator")
        let boundaryKB = formatter.format(bytesPerSecond: 999_999)
        assert(boundaryKB == "1000 KB/s", "1000 KB/s must not contain comma")
        count += 1

        // MARK: - Group G: NetworkSpeed Model Integration

        // Test 22: SpeedFormatter with NetworkSpeed instances
        let speed1 = NetworkSpeed(bytesPerSecond: 2_450_000)
        assert(formatter.format(speed1) == "2.45 MB/s", "NetworkSpeed 2.45 MB/s formatting failed")
        let details1 = formatter.formatDetails(speed1)
        assert(details1.unit == .megabytesPerSecond, "Unit must be MB/s")
        assert(details1.value == 2.45, "Value must be 2.45")
        count += 1

        // Test 23: Zero speed from elapsed seconds
        let zeroSpeed = NetworkSpeed(bytes: 0, elapsedSeconds: 1.0)
        assert(formatter.format(zeroSpeed) == "0 KB/s", "Zero-byte NetworkSpeed must format as 0 KB/s")
        count += 1

        return count
    }
}
