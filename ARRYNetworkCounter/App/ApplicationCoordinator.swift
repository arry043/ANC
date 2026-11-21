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

    /// Indicates whether the application monitoring lifecycle is actively running.
    @Published public private(set) var isRunning: Bool = false

    /// Underlying preferences store.
    private let preferencesStore: any PreferencesStoring

    /// Network monitor instance injected for lifecycle management.
    private let networkMonitor: (any NetworkMonitoring)?

    /// Network speed calculation engine.
    private let speedCalculator: NetworkSpeedCalculator

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
    ///   - initialPreferences: Initial preferences to bootstrap state before async load.
    public init(
        preferencesStore: any PreferencesStoring = UserDefaultsPreferencesStore(),
        networkMonitor: (any NetworkMonitoring)? = NetworkPathManager(),
        speedCalculator: NetworkSpeedCalculator = NetworkSpeedCalculator(),
        initialPreferences: AppPreferences = .default
    ) {
        self.preferencesStore = preferencesStore
        self.networkMonitor = networkMonitor
        self.speedCalculator = speedCalculator
        self.preferences = initialPreferences
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
            } else {
                speedResult = .noActivePath
                latestMeasurement = nil
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
                            self.speedResult = .noActivePath
                            self.latestMeasurement = nil
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
                            }
                        } else {
                            await self.speedCalculator.reset()
                            self.speedResult = .noActivePath
                            self.latestMeasurement = nil
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
        speedResult = .noActivePath
        latestMeasurement = nil
        currentSnapshot = nil
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
