import AppKit
import Combine

/// Manages the lifecycle, display updates, and user interaction for the macOS menu bar status item.
///
/// `MenuBarManager` is isolated to `@MainActor` to safely manipulate AppKit UI components (`NSStatusItem`, `NSMenu`).
/// It observes state published by `ApplicationCoordinator` and delegates rendering to `MenuBarRenderer`.
@MainActor
public final class MenuBarManager: NSObject {
    /// Native macOS menu bar status item.
    public private(set) var statusItem: NSStatusItem?

    /// Injected application coordinator.
    public let coordinator: ApplicationCoordinator

    /// Last rendered content cache to prevent redundant UI redraws.
    public private(set) var lastRenderedContent: MenuBarContent?

    /// Indicates whether the manager is actively tracking coordinator updates.
    public private(set) var isRunning: Bool = false

    /// Optional callback invoked when the Settings menu action is triggered.
    public var onOpenSettings: (() -> Void)?

    /// Set of Combine subscriptions.
    private var cancellables: Set<AnyCancellable> = []

    /// Creates a new `MenuBarManager`.
    ///
    /// - Parameter coordinator: Injected application coordinator.
    public init(coordinator: ApplicationCoordinator) {
        self.coordinator = coordinator
        super.init()
    }

    /// Starts menu bar integration: creates the status item, builds the context menu, and subscribes to coordinator updates.
    public func start() {
        guard !isRunning else { return }
        isRunning = true

        createStatusItemIfNeeded()
        updateContent()
        subscribeToCoordinatorUpdates()
    }

    /// Stops menu bar integration: removes the status item and cancels all observations.
    public func stop() {
        guard isRunning else { return }
        isRunning = false

        cancellables.removeAll()

        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }

        lastRenderedContent = nil
    }

    /// Creates and configures the native `NSStatusItem` if not already created.
    public func createStatusItemIfNeeded() {
        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.target = self
            button.action = #selector(statusItemButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let menu = MenuBarMenuBuilder.buildMenu(
            target: self,
            settingsAction: #selector(handleSettingsAction),
            quitAction: #selector(handleQuitAction)
        )
        item.menu = menu

        self.statusItem = item
    }

    /// Pulls current application state from `ApplicationCoordinator`, constructs `MenuBarContent`, and updates the status item.
    public func updateContent() {
        let content = currentContentFromCoordinator()

        // Avoid unnecessary redrawing if rendered content has not changed
        if let last = lastRenderedContent, last == content {
            return
        }

        lastRenderedContent = content

        if let button = statusItem?.button {
            let attributed = MenuBarRenderer.render(content: content)
            button.attributedTitle = attributed
            button.setAccessibilityLabel(MenuBarRenderer.renderPlainText(content: content))
        }
    }

    /// Derives a clean `MenuBarContent` model from active coordinator state using `MenuBarContentBuilder`.
    public func currentContentFromCoordinator() -> MenuBarContent {
        MenuBarContentBuilder.build(
            preferences: coordinator.preferences,
            pathState: coordinator.pathState,
            latestMeasurement: coordinator.latestMeasurement,
            dominantDirection: coordinator.dominantDirection
        )
    }

    // MARK: - Subscriptions

    private func subscribeToCoordinatorUpdates() {
        coordinator.$latestMeasurement
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateContent() }
            .store(in: &cancellables)

        coordinator.$dominantDirection
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateContent() }
            .store(in: &cancellables)

        coordinator.$pathState
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateContent() }
            .store(in: &cancellables)

        coordinator.$preferences
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateContent() }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func statusItemButtonClicked(_ sender: Any?) {
        // When menu is set on NSStatusItem, macOS handles pop-up automatically.
    }

    @objc public func handleSettingsAction() {
        if let onOpenSettings = onOpenSettings {
            onOpenSettings()
        } else {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc public func handleQuitAction() {
        NSApp.terminate(nil)
    }
}
