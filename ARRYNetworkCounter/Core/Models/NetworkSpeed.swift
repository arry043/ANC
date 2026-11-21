import Foundation

/// Represents a network transfer speed in bytes per second.
///
/// `NetworkSpeed` is an immutable, concurrency-safe value type that models raw transfer rate.
/// It enforces non-negative speed values and uses bytes per second (B/s) exclusively,
/// avoiding bits-per-second conversion or UI-specific formatting.
public struct NetworkSpeed: Sendable, Equatable, Comparable, Hashable {
    /// Raw transfer rate measured strictly in bytes per second.
    public let bytesPerSecond: Double

    /// A constant representing zero network throughput (0 B/s).
    public static let zero = NetworkSpeed(bytesPerSecond: 0)

    /// Creates a new `NetworkSpeed` instance.
    ///
    /// Any negative or non-finite values (such as NaN or Infinity) are safely clamped to 0.0.
    ///
    /// - Parameter bytesPerSecond: The transfer rate in bytes per second.
    public init(bytesPerSecond: Double) {
        if bytesPerSecond.isFinite && bytesPerSecond > 0 {
            self.bytesPerSecond = bytesPerSecond
        } else {
            self.bytesPerSecond = 0
        }
    }

    /// Creates a new `NetworkSpeed` from a byte count transferred over a given elapsed time.
    ///
    /// If `elapsedSeconds` is zero, negative, or non-finite, the resulting speed is safely clamped to zero.
    ///
    /// - Parameters:
    ///   - bytes: Total number of bytes transferred.
    ///   - elapsedSeconds: The elapsed time in seconds.
    public init(bytes: UInt64, elapsedSeconds: Double) {
        if elapsedSeconds.isFinite && elapsedSeconds > 0 {
            self.init(bytesPerSecond: Double(bytes) / elapsedSeconds)
        } else {
            self.init(bytesPerSecond: 0)
        }
    }

    /// Indicates whether the speed is strictly zero.
    public var isZero: Bool {
        bytesPerSecond == 0
    }

    /// Indicates whether meaningful positive network throughput exists.
    public var isPositive: Bool {
        bytesPerSecond > 0
    }

    // MARK: - Comparable

    public static func < (lhs: NetworkSpeed, rhs: NetworkSpeed) -> Bool {
        lhs.bytesPerSecond < rhs.bytesPerSecond
    }
}
