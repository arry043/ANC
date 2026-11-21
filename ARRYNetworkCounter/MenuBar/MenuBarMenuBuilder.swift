import AppKit

/// Builds native macOS context menu attached to the menu bar status item.
@MainActor
public final class MenuBarMenuBuilder: NSObject {
    /// Builds the primary context menu for ARRY Network Counter.
    ///
    /// - Parameters:
    ///   - target: Action target responder (typically `MenuBarManager`).
    ///   - settingsAction: Selector invoked when "Settings..." is selected.
    ///   - quitAction: Selector invoked when "Quit ARRY Network Counter" is selected.
    /// - Returns: A configured `NSMenu` instance.
    public static func buildMenu(
        target: AnyObject?,
        settingsAction: Selector?,
        quitAction: Selector?
    ) -> NSMenu {
        let menu = NSMenu(title: "ARRY Network Counter")

        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: settingsAction,
            keyEquivalent: ","
        )
        settingsItem.target = target
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit ARRY Network Counter",
            action: quitAction,
            keyEquivalent: "q"
        )
        quitItem.target = target
        menu.addItem(quitItem)

        return menu
    }
}
