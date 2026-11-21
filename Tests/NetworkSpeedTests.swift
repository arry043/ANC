import Foundation

/// Unit test suite for `NetworkSpeed`.
public enum NetworkSpeedTests {
    public static func run() throws -> Int {
        var count = 0

        // Test 1: Zero speed constant
        let zero = NetworkSpeed.zero
        assert(zero.bytesPerSecond == 0, "Zero speed must have 0 bytesPerSecond")
        assert(zero.isZero, "Zero speed must return isZero == true")
        assert(!zero.isPositive, "Zero speed must return isPositive == false")
        count += 1

        // Test 2: Positive speed initialization
        let speed = NetworkSpeed(bytesPerSecond: 1024.5)
        assert(speed.bytesPerSecond == 1024.5, "Positive speed must match initialized value")
        assert(!speed.isZero, "Positive speed must not be zero")
        assert(speed.isPositive, "Positive speed must be positive")
        count += 1

        // Test 3: Negative speed clamped to zero
        let negativeSpeed = NetworkSpeed(bytesPerSecond: -500.0)
        assert(negativeSpeed.bytesPerSecond == 0, "Negative speed must be clamped to 0")
        assert(negativeSpeed.isZero, "Negative speed must be zero after clamping")
        count += 1

        // Test 4: Non-finite values clamped to zero
        let nanSpeed = NetworkSpeed(bytesPerSecond: Double.nan)
        let infSpeed = NetworkSpeed(bytesPerSecond: Double.infinity)
        assert(nanSpeed.bytesPerSecond == 0, "NaN speed must be clamped to 0")
        assert(infSpeed.bytesPerSecond == 0, "Infinity speed must be clamped to 0")
        count += 1

        // Test 5: Equality and hashing
        let speedA = NetworkSpeed(bytesPerSecond: 2048.0)
        let speedB = NetworkSpeed(bytesPerSecond: 2048.0)
        let speedC = NetworkSpeed(bytesPerSecond: 4096.0)
        assert(speedA == speedB, "Speeds with equal bytesPerSecond must be equal")
        assert(speedA != speedC, "Speeds with different bytesPerSecond must not be equal")
        assert(speedA.hashValue == speedB.hashValue, "Equal speeds must have equal hash values")
        count += 1

        // Test 6: Comparison (Comparable)
        assert(speedA < speedC, "2048 B/s must be less than 4096 B/s")
        assert(speedC > speedA, "4096 B/s must be greater than 2048 B/s")
        assert(!(speedA < speedB), "Identical speeds must not be strictly less")
        count += 1

        // Test 7: Byte count and elapsed seconds initialization
        let calculated = NetworkSpeed(bytes: 10_000, elapsedSeconds: 2.0)
        assert(calculated.bytesPerSecond == 5000.0, "10000 bytes over 2.0s must equal 5000 B/s")
        count += 1

        // Test 8: Byte count with invalid or zero elapsed seconds
        let zeroElapsed = NetworkSpeed(bytes: 5000, elapsedSeconds: 0.0)
        let negElapsed = NetworkSpeed(bytes: 5000, elapsedSeconds: -1.0)
        assert(zeroElapsed.bytesPerSecond == 0, "Zero elapsed time must produce zero speed")
        assert(negElapsed.bytesPerSecond == 0, "Negative elapsed time must produce zero speed")
        count += 1

        return count
    }
}
