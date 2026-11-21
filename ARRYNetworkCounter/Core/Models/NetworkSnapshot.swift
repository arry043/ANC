import Foundation

/// An immutable snapshot of network byte counter measurements at a specific point in time.
///
/// `NetworkSnapshot` captures cumulative received and transmitted byte counters along with
/// the timestamp and associated interface metadata, providing the necessary input for subsequent
/// delta-based speed calculations in Phase 05.
public struct NetworkSnapshot: Sendable, Equatable, Hashable {
    /// Cumulative count of bytes received across the interface.
    public let receivedBytes: UInt64

    /// Cumulative count of bytes transmitted across the interface.
    public let transmittedBytes: UInt64

    /// Wall-clock timestamp when this snapshot was captured.
    public let timestamp: Date

    /// Monotonic timestamp used for accurate elapsed time calculation, unaffected by clock adjustments.
    public let monotonicTimeNanoseconds: UInt64

    /// The network interface associated with this measurement snapshot, if identified.
    public let interface: NetworkInterface?

    /// Creates a new `NetworkSnapshot`.
    ///
    /// - Parameters:
    ///   - receivedBytes: Cumulative received bytes count.
    ///   - transmittedBytes: Cumulative transmitted bytes count.
    ///   - timestamp: Wall-clock timestamp of the sample (defaults to current date).
    ///   - monotonicTimeNanoseconds: Monotonic timestamp in nanoseconds (defaults to current continuous clock time).
    ///   - interface: Optional network interface metadata.
    public init(
        receivedBytes: UInt64,
        transmittedBytes: UInt64,
        timestamp: Date = Date(),
        monotonicTimeNanoseconds: UInt64 = DispatchTime.now().uptimeNanoseconds,
        interface: NetworkInterface? = nil
    ) {
        self.receivedBytes = receivedBytes
        self.transmittedBytes = transmittedBytes
        self.timestamp = timestamp
        self.monotonicTimeNanoseconds = monotonicTimeNanoseconds
        self.interface = interface
    }

    /// A baseline zero snapshot useful for initialization and testing.
    public static let zero = NetworkSnapshot(
        receivedBytes: 0,
        transmittedBytes: 0,
        timestamp: Date(timeIntervalSince1970: 0),
        monotonicTimeNanoseconds: 0,
        interface: nil
    )
}
