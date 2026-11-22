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

/// Actor managing native macOS network path monitoring and interface statistics.
///
/// `NetworkPathManager` oversees the `NWPathMonitor` lifecycle, retrieves BSD interface statistics,
/// correlates active network paths with relevant system interfaces, and emits immutable snapshots.
public actor NetworkPathManager: NetworkMonitoring {
    /// Indicates whether active network path monitoring is currently running.
    public private(set) var isMonitoring: Bool = false

    /// The most recent network path state.
    public private(set) var currentPathState: NetworkPathState

    /// Most recent network measurement snapshot containing cumulative byte counters.
    public private(set) var currentSnapshot: NetworkSnapshot? = nil

    /// The most recent interface selection result.
    public private(set) var currentSelectionResult: NetworkInterfaceSelector.SelectionResult = .noActivePath

    /// Underlying path provider (defaults to `SystemPathMonitorProvider`).
    private let provider: any PathMonitorProviding

    /// Underlying interface statistics provider (defaults to `SystemNetworkInterfaceProvider`).
    private let interfaceProvider: any NetworkInterfaceProviding

    /// Interface selector matching path state to interface statistics.
    private let interfaceSelector: NetworkInterfaceSelector

    /// Dedicated serial queue for path monitor callbacks.
    private let monitorQueue = DispatchQueue(label: "in.arrry.networkcounter.pathmonitor", qos: .utility)

    /// Session identifier used to reject late or stale callbacks from terminated sessions.
    private var currentSessionID: UInt64 = 0

    /// Registered active subscribers to the path state stream.
    private var pathContinuations: [UUID: AsyncStream<NetworkPathState>.Continuation] = [:]

    /// Registered active subscribers to the snapshot stream.
    private var snapshotContinuations: [UUID: AsyncStream<NetworkSnapshot>.Continuation] = [:]

    /// Periodic background task sampling network interface counters at designated intervals.
    private var samplingTask: Task<Void, Never>?

    /// Indicates whether a periodic sampling task is actively running.
    public var isSamplingTaskActive: Bool {
        samplingTask != nil && !(samplingTask?.isCancelled ?? true)
    }

    /// Creates a new `NetworkPathManager`.
    ///
    /// - Parameters:
    ///   - provider: The path monitor provider (defaults to `SystemPathMonitorProvider`).
    ///   - interfaceProvider: The interface statistics provider (defaults to `SystemNetworkInterfaceProvider`).
    ///   - interfaceSelector: The interface selector (defaults to `NetworkInterfaceSelector`).
    ///   - initialState: Initial path state before monitoring begins (defaults to `.unsatisfied`).
    public init(
        provider: any PathMonitorProviding = SystemPathMonitorProvider(),
        interfaceProvider: any NetworkInterfaceProviding = SystemNetworkInterfaceProvider(),
        interfaceSelector: NetworkInterfaceSelector = NetworkInterfaceSelector(),
        initialState: NetworkPathState = .unsatisfied
    ) {
        self.provider = provider
        self.interfaceProvider = interfaceProvider
        self.interfaceSelector = interfaceSelector
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

    /// Initiates network path monitoring and initial interface snapshot evaluation.
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

        // Single active sampling task enforcement
        samplingTask?.cancel()
        samplingTask = Task { [weak self, session] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(AppConfiguration.defaultSamplingIntervalSeconds * 1_000_000_000))
                guard !Task.isCancelled else { break }
                guard let self = self else { break }
                await self.performPeriodicSample(sessionID: session)
            }
        }

        // Initial snapshot evaluation
        _ = try? await sampleCurrentSnapshot()
    }

    /// Halts active network path monitoring, resets snapshots, and invalidates active streams.
    public func stopMonitoring() async {
        guard isMonitoring else { return }

        isMonitoring = false
        currentSessionID &+= 1

        samplingTask?.cancel()
        samplingTask = nil

        provider.cancelMonitoring()

        currentSnapshot = nil
        currentSelectionResult = .noActivePath

        for continuation in pathContinuations.values {
            continuation.finish()
        }
        pathContinuations.removeAll()

        for continuation in snapshotContinuations.values {
            continuation.finish()
        }
        snapshotContinuations.removeAll()
    }

    private func performPeriodicSample(sessionID: UInt64) async {
        guard isMonitoring, sessionID == currentSessionID else { return }
        _ = try? await sampleCurrentSnapshot()
    }

    /// Samples fresh interface statistics, re-evaluates the active interface, and emits an updated snapshot.
    @discardableResult
    public func sampleCurrentSnapshot() async throws -> NetworkSnapshot? {
        guard isMonitoring else { return nil }

        let stats: [NetworkInterfaceStatistics]
        do {
            stats = try await interfaceProvider.currentInterfaceStatistics()
        } catch {
            self.currentSnapshot = nil
            self.currentSelectionResult = .enumerationFailed(message: error.localizedDescription)
            AppLogger.network.notice("Interface statistics retrieval failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }

        let result = interfaceSelector.selectInterface(pathState: currentPathState, statistics: stats)
        self.currentSelectionResult = result

        if case .selected(let selectedStats, _) = result {
            let snapshot = NetworkSnapshot(
                receivedBytes: selectedStats.receivedBytes,
                transmittedBytes: selectedStats.transmittedBytes,
                timestamp: selectedStats.timestamp,
                monotonicTimeNanoseconds: selectedStats.monotonicTimeNanoseconds,
                interface: selectedStats.toNetworkInterface()
            )
            self.currentSnapshot = snapshot
            for continuation in snapshotContinuations.values {
                continuation.yield(snapshot)
            }
            return snapshot
        } else {
            self.currentSnapshot = nil
            return nil
        }
    }

    /// Processes an incoming path state update from the provider.
    ///
    /// Re-evaluates interface selection and emits updated path state and snapshots.
    public func handlePathUpdate(_ newState: NetworkPathState, sessionID: UInt64) async {
        guard isMonitoring, sessionID == currentSessionID else {
            return
        }

        // Suppress duplicate consecutive states
        guard newState != currentPathState else {
            return
        }

        let previousStatus = currentPathState.status
        currentPathState = newState

        if newState.status != .satisfied {
            self.currentSnapshot = nil
            self.currentSelectionResult = .noActivePath
            AppLogger.network.info("Network path transitioned to unsatisfied (previous: \(previousStatus.rawValue, privacy: .public)). Baseline cleared.")
        } else {
            AppLogger.network.info("Network path transitioned to satisfied (\(newState.activeInterfaceName ?? "unknown", privacy: .public)).")
        }

        for continuation in pathContinuations.values {
            continuation.yield(newState)
        }

        // Re-evaluate interface selection following path state transition
        _ = try? await sampleCurrentSnapshot()
    }

    private func removePathContinuation(id: UUID) {
        pathContinuations.removeValue(forKey: id)
    }

    private func removeSnapshotContinuation(id: UUID) {
        snapshotContinuations.removeValue(forKey: id)
    }
}
