import Foundation

/// Central application coordinator orchestrating lifecycle, preferences, and monitoring.
///
/// `ApplicationCoordinator` is isolated to `@MainActor` to safely coordinate UI-facing state
/// and manage lifecycle interactions between application services and SwiftUI/AppKit presentation.
@MainActor
public final class ApplicationCoordinator: ObservableObject {
    /// Active user preferences.
    @Published public private(set) var preferences: AppPreferences

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
        speedCalculator: NetworkSpeedCalculator = NetworkSpeedCalculator(),
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
    public func start() async {
        guard !isRunning else { return }

        isRunning = true
        preferences = await preferencesStore.loadPreferences()

        if let monitor = networkMonitor {
            pathState = await monitor.currentPathState
            currentSnapshot = await monitor.currentSnapshot
            if pathState.status == .satisfied, let snap = currentSnapshot {
                let result = await speedCalculator.calculateSpeed(from: snap)
                speedResult = result
                latestMeasurement = result.measurement
                if let measurement = result.measurement {
                    let decision = await directionEngine.evaluate(measurement)
                    dominantDirection = decision.direction
                } else {
                    dominantDirection = .download
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
                                self.latestMeasurement = measurement
                                let decision = await self.directionEngine.evaluate(measurement)
                                self.dominantDirection = decision.direction
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
            } catch {
                // Safe recovery if monitor fails to start
            }
        }
    }

    /// Stops the application coordination lifecycle and halts active monitoring.
    public func stop() async {
        guard isRunning else { return }

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
    }

    /// Updates application preferences, persisting them to storage and updating published state.
    ///
    /// - Parameter newPreferences: The updated preferences.
    public func updatePreferences(_ newPreferences: AppPreferences) async throws {
        try await preferencesStore.savePreferences(newPreferences)
        self.preferences = newPreferences
    }
}
