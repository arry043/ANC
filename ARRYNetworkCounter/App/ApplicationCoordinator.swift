import Foundation

/// Current lifecycle state of the application coordinator.
public enum ApplicationLifecycleState: String, Sendable, Equatable, Hashable {
    case notStarted = "notStarted"
    case starting = "starting"
    case running = "running"
    case stopping = "stopping"
    case stopped = "stopped"
    case failed = "failed"
}

/// Central application coordinator orchestrating lifecycle, preferences, and monitoring.
///
/// `ApplicationCoordinator` is isolated to `@MainActor` to safely coordinate UI-facing state
/// and manage lifecycle interactions between application services and SwiftUI/AppKit presentation.
@MainActor
public final class ApplicationCoordinator: ObservableObject {
    /// Active user preferences.
    @Published public private(set) var preferences: AppPreferences

    /// Current operational lifecycle state of the coordinator.
    @Published public private(set) var lifecycleState: ApplicationLifecycleState = .notStarted

    /// Current network path state published for UI presentation and subsystem coordination.
    @Published public private(set) var pathState: NetworkPathState = .unsatisfied

    /// Current network measurement snapshot containing cumulative byte counters.
    @Published public private(set) var currentSnapshot: NetworkSnapshot? = nil

    /// Current network speed calculation result.
    @Published public private(set) var speedResult: SpeedCalculationResult = .noActivePath

    /// Latest calculated speed measurement, if available.
    @Published public private(set) var latestMeasurement: SpeedMeasurement? = nil

    /// Current dominant traffic direction determined by hysteresis switching rules.
    @Published public private(set) var dominantDirection: NetworkDirection = .download

    /// Indicates whether the application monitoring lifecycle is actively running.
    @Published public private(set) var isRunning: Bool = false

    /// Underlying preferences store.
    private let preferencesStore: any PreferencesStoring

    /// Network monitor instance injected for lifecycle management.
    private let networkMonitor: (any NetworkMonitoring)?

    /// Network speed calculation engine.
    private let speedCalculator: NetworkSpeedCalculator

    /// Dominant direction switching hysteresis engine.
    private let directionEngine: DominantDirectionEngine

    /// Observation task tracking asynchronous path changes.
    private var pathObservationTask: Task<Void, Never>?

    /// Observation task tracking asynchronous snapshot updates.
    private var snapshotObservationTask: Task<Void, Never>?

    /// Creates a new `ApplicationCoordinator`.
    ///
    /// - Parameters:
    ///   - preferencesStore: Storage provider conforming to `PreferencesStoring`.
    ///   - networkMonitor: Optional network monitor conforming to `NetworkMonitoring`.
    ///   - speedCalculator: Speed calculation engine conforming to `NetworkSpeedCalculator`.
    ///   - directionEngine: Direction switching engine conforming to `DominantDirectionEngine`.
    ///   - initialPreferences: Initial preferences to bootstrap state before async load.
    public init(
        preferencesStore: any PreferencesStoring = UserDefaultsPreferencesStore(),
        networkMonitor: (any NetworkMonitoring)? = NetworkPathManager(),
        speedCalculator: NetworkSpeedCalculator = NetworkSpeedCalculator(maximumMeasurementIntervalSeconds: NetworkSpeedCalculator.defaultMaximumIntervalSeconds),
        directionEngine: DominantDirectionEngine = DominantDirectionEngine(),
        initialPreferences: AppPreferences = .default
    ) {
        self.preferencesStore = preferencesStore
        self.networkMonitor = networkMonitor
        self.speedCalculator = speedCalculator
        self.directionEngine = directionEngine
        self.preferences = initialPreferences
        self.dominantDirection = .download
    }

    /// Starts the application coordination lifecycle: loads preferences and activates monitoring.
    ///
    /// Idempotent: repeated calls while starting or running are safe no-ops.
    public func start() async {
        guard lifecycleState != .running && lifecycleState != .starting else { return }

        lifecycleState = .starting
        isRunning = true

        // Clean up any stale observation tasks before starting new ones
        pathObservationTask?.cancel()
        pathObservationTask = nil
        snapshotObservationTask?.cancel()
        snapshotObservationTask = nil

        preferences = await preferencesStore.loadPreferences()

        if let monitor = networkMonitor {
            pathState = await monitor.currentPathState
            currentSnapshot = await monitor.currentSnapshot
            if pathState.status == .satisfied, let snap = currentSnapshot {
                let result = await speedCalculator.calculateSpeed(from: snap)
                speedResult = result
                if let measurement = result.measurement {
                    let decision = await directionEngine.evaluate(measurement)
                    dominantDirection = decision.direction
                    latestMeasurement = measurement
                } else {
                    dominantDirection = .download
                    latestMeasurement = nil
                }
            } else {
                speedResult = .noActivePath
                latestMeasurement = nil
                dominantDirection = .download
            }

            do {
                try await monitor.startMonitoring()
                let pathStream = await monitor.pathStateStream
                pathObservationTask = Task { [weak self] in
                    for await newPathState in pathStream {
                        guard !Task.isCancelled, let self = self, self.isRunning else { break }
                        self.pathState = newPathState
                        if newPathState.status != .satisfied {
                            await self.speedCalculator.reset()
                            await self.directionEngine.reset()
                            self.speedResult = .noActivePath
                            self.latestMeasurement = nil
                            self.dominantDirection = .download
                        }
                    }
                }

                let snapshotStream = await monitor.snapshotStream
                snapshotObservationTask = Task { [weak self] in
                    for await newSnapshot in snapshotStream {
                        guard !Task.isCancelled, let self = self, self.isRunning else { break }
                        self.currentSnapshot = newSnapshot
                        if self.pathState.status == .satisfied {
                            let result = await self.speedCalculator.calculateSpeed(from: newSnapshot)
                            self.speedResult = result
                            if let measurement = result.measurement {
                                let decision = await self.directionEngine.evaluate(measurement)
                                self.dominantDirection = decision.direction
                                self.latestMeasurement = measurement
                            } else {
                                self.latestMeasurement = nil
                                if case .baselineReset = result {
                                    await self.directionEngine.reset()
                                    self.dominantDirection = .download
                                }
                            }
                        } else {
                            await self.speedCalculator.reset()
                            await self.directionEngine.reset()
                            self.speedResult = .noActivePath
                            self.latestMeasurement = nil
                            self.dominantDirection = .download
                        }
                    }
                }
                lifecycleState = .running
            } catch {
                lifecycleState = .failed
                isRunning = false
            }
        } else {
            lifecycleState = .running
        }
    }

    /// Stops the application coordination lifecycle and halts active monitoring.
    ///
    /// Idempotent: repeated calls while stopped or not started are safe no-ops.
    public func stop() async {
        guard lifecycleState != .stopped && lifecycleState != .notStarted else { return }

        lifecycleState = .stopping

        pathObservationTask?.cancel()
        pathObservationTask = nil

        snapshotObservationTask?.cancel()
        snapshotObservationTask = nil

        if let monitor = networkMonitor {
            await monitor.stopMonitoring()
        }

        await speedCalculator.reset()
        await directionEngine.reset()
        speedResult = .noActivePath
        latestMeasurement = nil
        currentSnapshot = nil
        dominantDirection = .download
        isRunning = false
        lifecycleState = .stopped
    }

    /// Updates application preferences synchronously on MainActor, persisting to storage and updating published state.
    ///
    /// - Parameter newPreferences: The updated preferences.
    public func applyPreferences(_ newPreferences: AppPreferences) {
        if let store = preferencesStore as? PreferencesStore {
            store.savePreferences(newPreferences)
        } else {
            Task { [weak self] in
                guard let self = self else { return }
                try? await self.preferencesStore.savePreferences(newPreferences)
            }
        }
        self.preferences = newPreferences
    }

    /// Updates application preferences, persisting them to storage and updating published state.
    ///
    /// - Parameter newPreferences: The updated preferences.
    public func updatePreferences(_ newPreferences: AppPreferences) async throws {
        try await preferencesStore.savePreferences(newPreferences)
        self.preferences = newPreferences
    }
}
