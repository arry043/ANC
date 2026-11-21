import Foundation

/// Defines the contract for network monitoring services.
///
/// Implementations of this protocol are responsible for observing network state changes,
/// collecting counter snapshots, and providing asynchronous update streams without coupling to UI layers.
public protocol NetworkMonitoring: Sendable {
    /// Indicates whether active network sampling is currently running.
    var isMonitoring: Bool { get async }

    /// The most recent network measurement snapshot, if available.
    var currentSnapshot: NetworkSnapshot? { get async }

    /// Asynchronous stream yielding periodic or event-driven network snapshots.
    var snapshotStream: AsyncStream<NetworkSnapshot> { get async }

    /// Initiates continuous network monitoring.
    func startMonitoring() async throws

    /// Halts active network monitoring and cleans up underlying system resources.
    func stopMonitoring() async
}
