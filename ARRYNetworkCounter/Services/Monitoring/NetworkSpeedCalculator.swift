import Foundation

/// Represents the calculated transfer speed metrics for both download and upload directions.
public struct SpeedMeasurement: Sendable, Equatable, Hashable {
    /// Download transfer rate in bytes per second.
    public let download: NetworkSpeed

    /// Upload transfer rate in bytes per second.
    public let upload: NetworkSpeed

    /// Actual elapsed monotonic time in seconds used for this calculation.
    public let elapsedSeconds: Double

    /// Monotonic timestamp in nanoseconds when this sample was captured.
    public let monotonicTimeNanoseconds: UInt64

    /// The network interface on which this throughput was measured, if known.
    public let interface: NetworkInterface?

    /// Creates a new `SpeedMeasurement`.
    ///
    /// - Parameters:
    ///   - download: Download transfer speed.
    ///   - upload: Upload transfer speed.
    ///   - elapsedSeconds: Actual elapsed interval in seconds.
    ///   - monotonicTimeNanoseconds: Monotonic timestamp in nanoseconds.
    ///   - interface: Optional interface identity.
    public init(
        download: NetworkSpeed,
        upload: NetworkSpeed,
        elapsedSeconds: Double,
        monotonicTimeNanoseconds: UInt64,
        interface: NetworkInterface? = nil
    ) {
        self.download = download
        self.upload = upload
        self.elapsedSeconds = elapsedSeconds
        self.monotonicTimeNanoseconds = monotonicTimeNanoseconds
        self.interface = interface
    }

    /// Convenience accessor for download throughput in raw bytes per second.
    public var downloadBytesPerSecond: Double {
        download.bytesPerSecond
    }

    /// Convenience accessor for upload throughput in raw bytes per second.
    public var uploadBytesPerSecond: Double {
        upload.bytesPerSecond
    }

    /// Indicates whether both download and upload transfer rates are zero.
    public var isZero: Bool {
        download.isZero && upload.isZero
    }

    /// Indicates whether positive transfer rate is observed in either direction.
    public var isPositive: Bool {
        download.isPositive || upload.isPositive
    }
}

/// The specific rationale when a calculation baseline is reset.
public enum BaselineResetReason: String, Sendable, Equatable, Codable {
    /// The selected network interface changed (e.g. Wi-Fi to Ethernet).
    case interfaceChanged
    /// A counter decreased unexpectedly (interface reset, reboot, or counter discontinuity).
    case counterDecreased
    /// Network connection was lost or disconnected.
    case disconnected
    /// Baseline was reset manually or during a lifecycle transition.
    case manualReset
}

/// The specific rationale when a network sample is rejected for calculation.
public enum SampleRejectionReason: String, Sendable, Equatable, Codable {
    /// The current monotonic timestamp is identical to the baseline timestamp (zero elapsed delta).
    case zeroElapsedNanoseconds
    /// The current monotonic timestamp is earlier than the baseline timestamp (reversed clock).
    case reversedTimestamp
    /// Elapsed seconds calculation produced a non-finite or non-positive value.
    case nonFiniteElapsedSeconds
}

/// Result of evaluating a network counter snapshot against the current calculation baseline.
public enum SpeedCalculationResult: Sendable, Equatable {
    /// A valid speed measurement calculated from two consecutive valid snapshots.
    case calculated(SpeedMeasurement)
    /// The initial snapshot established a new baseline; subsequent valid snapshot will yield a measurement.
    case baselineEstablished
    /// The baseline was reset due to an interface transition, counter decrease, or connection change.
    case baselineReset(reason: BaselineResetReason)
    /// The sample was rejected due to invalid timing without corrupting the existing valid baseline.
    case sampleRejected(reason: SampleRejectionReason)
    /// No active or satisfied network path exists.
    case noActivePath

    /// The calculated speed measurement, if this result represents a valid measurement.
    public var measurement: SpeedMeasurement? {
        if case .calculated(let m) = self {
            return m
        }
        return nil
    }

    /// Indicates whether this result contains a valid calculated measurement.
    public var isCalculated: Bool {
        measurement != nil
    }
}

/// Actor responsible for calculating download and upload network transfer speeds from consecutive snapshots.
///
/// `NetworkSpeedCalculator` enforces monotonic elapsed-time calculations, detects counter resets and interface
/// transitions, and produces immutable `SpeedCalculationResult` values.
public actor NetworkSpeedCalculator {
    /// The current baseline snapshot used for subsequent delta calculations.
    public private(set) var baselineSnapshot: NetworkSnapshot?

    /// Creates a new `NetworkSpeedCalculator`.
    ///
    /// - Parameter initialBaseline: Optional pre-existing baseline snapshot (defaults to `nil`).
    public init(initialBaseline: NetworkSnapshot? = nil) {
        self.baselineSnapshot = initialBaseline
    }

    /// Calculates transfer speeds by comparing `currentSnapshot` against the stored baseline.
    ///
    /// - Parameter currentSnapshot: The latest cumulative byte counter snapshot.
    /// - Returns: An explicit `SpeedCalculationResult` representing calculated speeds or the reason no speed was produced.
    public func calculateSpeed(from currentSnapshot: NetworkSnapshot) -> SpeedCalculationResult {
        // 1. If no baseline exists, establish one
        guard let previous = baselineSnapshot else {
            self.baselineSnapshot = currentSnapshot
            return .baselineEstablished
        }

        // 2. Validate interface identity
        if !haveSameInterfaceIdentity(previous: previous.interface, current: currentSnapshot.interface) {
            self.baselineSnapshot = currentSnapshot
            return .baselineReset(reason: .interfaceChanged)
        }

        // 3. Validate monotonic timestamp
        guard currentSnapshot.monotonicTimeNanoseconds > previous.monotonicTimeNanoseconds else {
            if currentSnapshot.monotonicTimeNanoseconds == previous.monotonicTimeNanoseconds {
                return .sampleRejected(reason: .zeroElapsedNanoseconds)
            } else {
                return .sampleRejected(reason: .reversedTimestamp)
            }
        }

        // 4. Validate elapsed seconds
        let elapsedNanos = currentSnapshot.monotonicTimeNanoseconds - previous.monotonicTimeNanoseconds
        let elapsedSeconds = Double(elapsedNanos) / 1_000_000_000.0
        guard elapsedSeconds.isFinite && elapsedSeconds > 0 else {
            return .sampleRejected(reason: .nonFiniteElapsedSeconds)
        }

        // 5. Detect counter decrease / reset
        guard currentSnapshot.receivedBytes >= previous.receivedBytes,
              currentSnapshot.transmittedBytes >= previous.transmittedBytes else {
            self.baselineSnapshot = currentSnapshot
            return .baselineReset(reason: .counterDecreased)
        }

        // 6. Calculate byte deltas
        let deltaReceived = currentSnapshot.receivedBytes - previous.receivedBytes
        let deltaTransmitted = currentSnapshot.transmittedBytes - previous.transmittedBytes

        // 7. Calculate speeds in bytes per second
        let downloadBps = Double(deltaReceived) / elapsedSeconds
        let uploadBps = Double(deltaTransmitted) / elapsedSeconds

        let downloadSpeed = NetworkSpeed(bytesPerSecond: downloadBps)
        let uploadSpeed = NetworkSpeed(bytesPerSecond: uploadBps)

        let measurement = SpeedMeasurement(
            download: downloadSpeed,
            upload: uploadSpeed,
            elapsedSeconds: elapsedSeconds,
            monotonicTimeNanoseconds: currentSnapshot.monotonicTimeNanoseconds,
            interface: currentSnapshot.interface
        )

        // 8. Update baseline to current snapshot for the next iteration
        self.baselineSnapshot = currentSnapshot

        return .calculated(measurement)
    }

    /// Resets the current calculation baseline (e.g., after network disconnection or monitoring stop).
    public func reset() {
        self.baselineSnapshot = nil
    }

    /// Compares two optional `NetworkInterface` instances to determine if they represent the same interface.
    private func haveSameInterfaceIdentity(previous: NetworkInterface?, current: NetworkInterface?) -> Bool {
        switch (previous, current) {
        case (nil, nil):
            return true
        case (let p?, let c?):
            if let pIndex = p.index, let cIndex = c.index {
                return pIndex == cIndex && p.name == c.name
            }
            return p.name == c.name
        default:
            return false
        }
    }
}
