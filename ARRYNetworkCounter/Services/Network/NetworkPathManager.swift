import Foundation
#if canImport(Network)
import Network
#endif

/// Abstraction allowing dependency injection and isolated testing of `NWPathMonitor` operations.
public protocol PathMonitorProviding: Sendable {
    /// Begins monitoring network path updates on the designated dispatch queue.
    func startMonitoring(
        on queue: DispatchQueue,
        pathUpdateHandler: @escaping @Sendable (NetworkPathState) -> Void
    )

    /// Halts active monitoring and releases the underlying system monitor.
    func cancelMonitoring()
}

#if canImport(Network)
/// Production implementation of `PathMonitorProviding` backed by Apple's `NWPathMonitor`.
public final class SystemPathMonitorProvider: PathMonitorProviding, @unchecked Sendable {
    private var monitor: NWPathMonitor?
    private let lock = NSLock()

    public init() {}

    public func startMonitoring(
        on queue: DispatchQueue,
        pathUpdateHandler: @escaping @Sendable (NetworkPathState) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }

        let monitor = NWPathMonitor()
        self.monitor = monitor

        monitor.pathUpdateHandler = { path in
            let state = NetworkPathState(nwPath: path)
            pathUpdateHandler(state)
        }

        monitor.start(queue: queue)
    }

    public func cancelMonitoring() {
        lock.lock()
        defer { lock.unlock() }

        monitor?.cancel()
        monitor = nil
    }
}
#endif

/// Thread-safe mock provider for unit testing path change scenarios.
public final class MockPathMonitorProvider: PathMonitorProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var updateHandler: (@Sendable (NetworkPathState) -> Void)?
    public private(set) var startCount = 0
    public private(set) var cancelCount = 0
    public private(set) var isRunning = false

    public init() {}

    public func startMonitoring(
        on queue: DispatchQueue,
        pathUpdateHandler: @escaping @Sendable (NetworkPathState) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }
        startCount += 1
        isRunning = true
        self.updateHandler = pathUpdateHandler
    }

    public func cancelMonitoring() {
        lock.lock()
        defer { lock.unlock() }
        cancelCount += 1
        isRunning = false
        self.updateHandler = nil
    }

    public func simulatePathUpdate(_ state: NetworkPathState) {
        let handler: (@Sendable (NetworkPathState) -> Void)?
        lock.lock()
        handler = self.updateHandler
        lock.unlock()
        handler?(state)
    }
}

/// Actor managing native macOS network path monitoring using Apple's Network.framework.
///
/// `NetworkPathManager` oversees the `NWPathMonitor` lifecycle, serializes path updates on an isolated queue,
/// converts system paths into immutable `NetworkPathState` values, and suppresses redundant consecutive states.
public actor NetworkPathManager: NetworkMonitoring {
    /// Indicates whether active network path monitoring is currently running.
    public private(set) var isMonitoring: Bool = false

    /// The most recent network path state.
    public private(set) var currentPathState: NetworkPathState

    /// Most recent network measurement snapshot (reserved for Phase 04/05 counter integration).
    public private(set) var currentSnapshot: NetworkSnapshot? = nil

    /// Underlying path provider (defaults to `SystemPathMonitorProvider`).
    private let provider: any PathMonitorProviding

    /// Dedicated serial queue for path monitor callbacks.
    private let monitorQueue = DispatchQueue(label: "in.arrry.networkcounter.pathmonitor", qos: .utility)

    /// Session identifier used to reject late or stale callbacks from terminated sessions.
    private var currentSessionID: UInt64 = 0

    /// Registered active subscribers to the path state stream.
    private var pathContinuations: [UUID: AsyncStream<NetworkPathState>.Continuation] = [:]

    /// Registered active subscribers to the snapshot stream.
    private var snapshotContinuations: [UUID: AsyncStream<NetworkSnapshot>.Continuation] = [:]

    /// Creates a new `NetworkPathManager`.
    ///
    /// - Parameters:
    ///   - provider: The path monitor provider (defaults to `SystemPathMonitorProvider`).
    ///   - initialState: Initial path state before monitoring begins (defaults to `.unsatisfied`).
    public init(
        provider: any PathMonitorProviding = SystemPathMonitorProvider(),
        initialState: NetworkPathState = .unsatisfied
    ) {
        self.provider = provider
        self.currentPathState = initialState
    }

    /// Asynchronous stream yielding network path state updates.
    public var pathStateStream: AsyncStream<NetworkPathState> {
        AsyncStream { continuation in
            let id = UUID()
            continuation.yield(self.currentPathState)
            self.pathContinuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.removePathContinuation(id: id)
                }
            }
        }
    }

    /// Asynchronous stream yielding network measurement snapshots.
    public var snapshotStream: AsyncStream<NetworkSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            if let snapshot = self.currentSnapshot {
                continuation.yield(snapshot)
            }
            self.snapshotContinuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.removeSnapshotContinuation(id: id)
                }
            }
        }
    }

    /// Initiates network path monitoring. Idempotent if already monitoring.
    public func startMonitoring() async throws {
        guard !isMonitoring else { return }

        isMonitoring = true
        currentSessionID &+= 1
        let session = currentSessionID

        provider.startMonitoring(on: monitorQueue) { [weak self, session] newState in
            Task { [weak self] in
                await self?.handlePathUpdate(newState, sessionID: session)
            }
        }
    }

    /// Halts active network path monitoring and invalidates active streams. Idempotent.
    public func stopMonitoring() async {
        guard isMonitoring else { return }

        isMonitoring = false
        currentSessionID &+= 1
        provider.cancelMonitoring()

        for continuation in pathContinuations.values {
            continuation.finish()
        }
        pathContinuations.removeAll()

        for continuation in snapshotContinuations.values {
            continuation.finish()
        }
        snapshotContinuations.removeAll()
    }

    /// Processes an incoming path state update from the provider.
    ///
    /// Discards updates from stale sessions or identical consecutive states.
    public func handlePathUpdate(_ newState: NetworkPathState, sessionID: UInt64) {
        guard isMonitoring, sessionID == currentSessionID else {
            return
        }

        // Suppress duplicate consecutive states
        guard newState != currentPathState else {
            return
        }

        currentPathState = newState

        for continuation in pathContinuations.values {
            continuation.yield(newState)
        }
    }

    private func removePathContinuation(id: UUID) {
        pathContinuations.removeValue(forKey: id)
    }

    private func removeSnapshotContinuation(id: UUID) {
        snapshotContinuations.removeValue(forKey: id)
    }
}
