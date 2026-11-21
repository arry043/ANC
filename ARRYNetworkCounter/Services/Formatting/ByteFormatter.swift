import Foundation

/// Supported decimal network speed transfer units based on SI decimal scaling (base 1000).
public enum SpeedUnit: String, Sendable, Equatable, Hashable, CaseIterable {
    /// Bytes per second (1 B/s).
    case bytesPerSecond = "B/s"
    /// Kilobytes per second (1,000 B/s).
    case kilobytesPerSecond = "KB/s"
    /// Megabytes per second (1,000,000 B/s).
    case megabytesPerSecond = "MB/s"
    /// Gigabytes per second (1,000,000,000 B/s).
    case gigabytesPerSecond = "GB/s"
    /// Terabytes per second (1,000,000,000,000 B/s).
    case terabytesPerSecond = "TB/s"

    /// The base-1000 multiplier scale relative to raw bytes per second.
    public var scale: Double {
        switch self {
        case .bytesPerSecond:
            return 1.0
        case .kilobytesPerSecond:
            return 1_000.0
        case .megabytesPerSecond:
            return 1_000_000.0
        case .gigabytesPerSecond:
            return 1_000_000_000.0
        case .terabytesPerSecond:
            return 1_000_000_000_000.0
        }
    }
}

/// Structured representation of a formatted network speed value.
public struct FormattedByteSpeed: Sendable, Equatable, Hashable {
    /// The numeric value scaled to the selected unit.
    public let value: Double

    /// The selected speed unit.
    public let unit: SpeedUnit

    /// The formatted numeric string (without unit), stripped of unnecessary trailing zeros.
    public let formattedValue: String

    /// The complete display string containing the formatted number and unit (e.g. "1.5 MB/s").
    public let displayString: String

    /// Creates a new `FormattedByteSpeed`.
    public init(
        value: Double,
        unit: SpeedUnit,
        formattedValue: String,
        displayString: String
    ) {
        self.value = value
        self.unit = unit
        self.formattedValue = formattedValue
        self.displayString = displayString
    }
}

/// Formatter responsible for converting raw byte-per-second values into human-readable SI decimal units.
///
/// Follows decimal base-1000 conversion per ADR-014, enforces a consistent 2-decimal-place policy with
/// trailing zero removal, formats zero throughput strictly as "0 KB/s", and uses POSIX decimal points.
public struct ByteFormatter: Sendable {
    /// Shared default formatter instance.
    public static let shared = ByteFormatter()

    /// POSIX locale ensuring deterministic '.' decimal separator across all user system locales.
    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    /// Creates a new `ByteFormatter`.
    public init() {}

    /// Formats a raw speed in bytes per second into a structured `FormattedByteSpeed`.
    ///
    /// - Parameter bytesPerSecond: Raw transfer speed in bytes per second.
    /// - Returns: A structured `FormattedByteSpeed` containing numeric value, unit, and formatted strings.
    public func format(bytesPerSecond: Double) -> FormattedByteSpeed {
        // Zero or non-finite / negative speed is explicitly formatted as "0 KB/s"
        guard bytesPerSecond.isFinite && bytesPerSecond > 0 else {
            return FormattedByteSpeed(
                value: 0.0,
                unit: .kilobytesPerSecond,
                formattedValue: "0",
                displayString: "0 KB/s"
            )
        }

        let unit: SpeedUnit
        let maxDecimals: Int

        // Automatic unit selection based on original raw speed
        if bytesPerSecond < 1_000.0 {
            unit = .bytesPerSecond
            maxDecimals = 0 // Integer display for B/s
        } else if bytesPerSecond < 1_000_000.0 {
            unit = .kilobytesPerSecond
            maxDecimals = 2
        } else if bytesPerSecond < 1_000_000_000.0 {
            unit = .megabytesPerSecond
            maxDecimals = 2
        } else if bytesPerSecond < 1_000_000_000_000.0 {
            unit = .gigabytesPerSecond
            maxDecimals = 2
        } else {
            unit = .terabytesPerSecond
            maxDecimals = 2
        }

        let scaledValue = bytesPerSecond / unit.scale

        let formattedNumber: String
        if maxDecimals == 0 {
            // Integer display for B/s: clamp positive values to at least 1 B/s to distinguish from zero
            let roundedInt = max(1, Int(scaledValue.rounded()))
            formattedNumber = String(roundedInt)
        } else {
            formattedNumber = formatDecimal(scaledValue, maxDecimals: maxDecimals)
        }

        return FormattedByteSpeed(
            value: scaledValue,
            unit: unit,
            formattedValue: formattedNumber,
            displayString: "\(formattedNumber) \(unit.rawValue)"
        )
    }

    /// Formats a raw speed in bytes per second directly into a display string (e.g. "2.45 MB/s").
    ///
    /// - Parameter bytesPerSecond: Raw transfer speed in bytes per second.
    /// - Returns: Readable display string.
    public func formatString(bytesPerSecond: Double) -> String {
        format(bytesPerSecond: bytesPerSecond).displayString
    }

    /// Formats a double with up to `maxDecimals` decimal places, stripping unnecessary trailing zeros.
    private func formatDecimal(_ value: Double, maxDecimals: Int) -> String {
        let formatted = String(format: "%.\(maxDecimals)f", locale: Self.posixLocale, value)
        if formatted.contains(".") {
            var trimmed = formatted
            while trimmed.hasSuffix("0") {
                trimmed.removeLast()
            }
            if trimmed.hasSuffix(".") {
                trimmed.removeLast()
            }
            return trimmed
        }
        return formatted
    }
}
