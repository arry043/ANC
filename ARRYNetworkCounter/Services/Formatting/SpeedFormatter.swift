import Foundation

/// Formatter that transforms `NetworkSpeed` domain models into human-readable display strings.
///
/// `SpeedFormatter` delegates conversion and decimal precision to `ByteFormatter`, providing a clean,
/// stateless, concurrency-safe API for converting raw transfer rates into presentation strings.
public struct SpeedFormatter: Sendable {
    /// Shared default speed formatter.
    public static let shared = SpeedFormatter()

    /// Underlying byte formatter providing decimal scaling and precision rules.
    private let byteFormatter: ByteFormatter

    /// Creates a new `SpeedFormatter`.
    ///
    /// - Parameter byteFormatter: The `ByteFormatter` instance to use (defaults to `.shared`).
    public init(byteFormatter: ByteFormatter = .shared) {
        self.byteFormatter = byteFormatter
    }

    /// Formats a `NetworkSpeed` value into a complete display string (e.g. "1.5 MB/s" or "0 KB/s").
    ///
    /// - Parameter speed: The `NetworkSpeed` to format.
    /// - Returns: Complete readable display string.
    public func format(_ speed: NetworkSpeed) -> String {
        byteFormatter.formatString(bytesPerSecond: speed.bytesPerSecond)
    }

    /// Formats a raw `bytesPerSecond` value into a complete display string.
    ///
    /// - Parameter bytesPerSecond: Raw transfer speed in bytes per second.
    /// - Returns: Complete readable display string.
    public func format(bytesPerSecond: Double) -> String {
        byteFormatter.formatString(bytesPerSecond: bytesPerSecond)
    }

    /// Formats a `NetworkSpeed` into a structured `FormattedByteSpeed` detailing numeric value, unit, and string.
    ///
    /// - Parameter speed: The `NetworkSpeed` to format.
    /// - Returns: Detailed `FormattedByteSpeed` record.
    public func formatDetails(_ speed: NetworkSpeed) -> FormattedByteSpeed {
        byteFormatter.format(bytesPerSecond: speed.bytesPerSecond)
    }

    /// Formats a raw `bytesPerSecond` value into a structured `FormattedByteSpeed`.
    ///
    /// - Parameter bytesPerSecond: Raw transfer speed in bytes per second.
    /// - Returns: Detailed `FormattedByteSpeed` record.
    public func formatDetails(bytesPerSecond: Double) -> FormattedByteSpeed {
        byteFormatter.format(bytesPerSecond: bytesPerSecond)
    }
}
