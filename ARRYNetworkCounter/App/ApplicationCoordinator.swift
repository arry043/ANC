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

    /// Indicates whether the application monitoring lifecycle is actively running.
    @Published public private(set) var isRunning: Bool = false

    /// Underlying preferences store.
    private let preferencesStore: any PreferencesStoring

    /// Network monitor instance injected for lifecycle management.
    private let networkMonitor: (any NetworkMonitoring)?

    /// Observation task tracking asynchronous path changes.
    private var pathObservationTask: Task<Void, Never>?

    /// Creates a new `ApplicationCoordinator`.
    ///
    /// - Parameters:
    ///   - preferencesStore: Storage provider conforming to `PreferencesStoring`.
    ///   - networkMonitor: Optional network monitor conforming to `NetworkMonitoring`.
    ///   - initialPreferences: Initial preferences to bootstrap state before async load.
    public init(
        preferencesStore: any PreferencesStoring = UserDefaultsPreferencesStore(),
        networkMonitor: (any NetworkMonitoring)? = NetworkPathManager(),
        initialPreferences: AppPreferences = .default
    ) {
        self.preferencesStore = preferencesStore
        self.networkMonitor = networkMonitor
        self.preferences = initialPreferences
    }

    /// Starts the application coordination lifecycle: loads preferences and activates monitoring.
    public func start() async {
        guard !isRunning else { return }

        preferences = await preferencesStore.loadPreferences()

        if let monitor = networkMonitor {
            pathState = await monitor.currentPathState
            do {
                try await monitor.startMonitoring()
                let stream = await monitor.pathStateStream
                pathObservationTask = Task { [weak self] in
                    for await newPathState in stream {
                        guard let self = self, self.isRunning else { break }
                        self.pathState = newPathState
                    }
                }
            } catch {
                // Safe recovery if monitor fails to start
            }
        }

        isRunning = true
    }

    /// Stops the application coordination lifecycle and halts active monitoring.
    public func stop() async {
        guard isRunning else { return }

        pathObservationTask?.cancel()
        pathObservationTask = nil

        if let monitor = networkMonitor {
            await monitor.stopMonitoring()
        }

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
