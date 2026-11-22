import SwiftUI
import AppKit

/// Available navigation tabs in the native macOS Settings interface.
public enum SettingsTab: String, CaseIterable, Identifiable {
    case preferences = "Preferences"
    case documentation = "Documentation"
    case about = "About"

    public var id: String { rawValue }

    public var systemIcon: String {
        switch self {
        case .preferences:
            return "slider.horizontal.3"
        case .documentation:
            return "book.pages"
        case .about:
            return "info.circle"
        }
    }
}

/// Native macOS Settings view providing compact, clean configuration of network display modes,
/// startup preferences, offline documentation reader, and polished application identity.
public struct SettingsView: View {
    @ObservedObject public var settingsManager: SettingsManager

    public init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    public var body: some View {
        Group {
            if let doc = settingsManager.viewingDocument {
                DocumentReaderView(document: doc) {
                    settingsManager.viewingDocument = nil
                }
            } else {
                mainContentView
            }
        }
        .frame(minWidth: 460, idealWidth: 480, minHeight: 500, idealHeight: 540)
    }

    // MARK: - Main Content with Tab Bar

    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Top Navigation Segmented Tab Bar
            tabSelector
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()

            // Active Tab View
            Group {
                switch settingsManager.selectedTab {
                case .preferences:
                    preferencesTab
                case .documentation:
                    documentationTab
                case .about:
                    aboutTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var tabSelector: some View {
        Picker("", selection: Binding(
            get: { settingsManager.selectedTab },
            set: { settingsManager.selectedTab = $0 }
        )) {
            ForEach(SettingsTab.allCases) { tab in
                Label(tab.rawValue, systemImage: tab.systemIcon)
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    // MARK: - Preferences Tab

    private var preferencesTab: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                Divider()

                displaySection

                Divider()

                generalSection

                Spacer(minLength: 10)
            }
            .padding(20)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 14) {
            appLogoThumbnail
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(AppConfiguration.appName)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Version \(AppConfiguration.Version.versionString) • Native macOS Network Monitor")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var appLogoThumbnail: some View {
        if let image = loadLogoImage() {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
        } else {
            Image(systemName: "network")
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .padding(4)
        }
    }

    // MARK: - Display Settings Section

    private var displaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Display Mode")
                .font(.headline)

            Picker("", selection: Binding(
                get: { settingsManager.preferences.displayMode },
                set: { settingsManager.updateDisplayMode($0) }
            )) {
                Text("Both Directions").tag(DisplayMode.bothDirections)
                Text("Single Direction — Manual").tag(DisplayMode.singleDirectionManual)
                Text("Single Direction — Automatic").tag(DisplayMode.singleDirectionAutomatic)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            conditionalDisplayControls
        }
    }

    @ViewBuilder
    private var conditionalDisplayControls: some View {
        switch settingsManager.preferences.displayMode {
        case .bothDirections:
            bothDirectionsControls
        case .singleDirectionManual:
            singleDirectionManualControls
        case .singleDirectionAutomatic:
            singleDirectionAutomaticControls
        }
    }

    private var bothDirectionsControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Presentation Style")
                .font(.subheadline)
                .fontWeight(.medium)

            Picker("", selection: Binding(
                get: { settingsManager.preferences.bothDirectionsStyle },
                set: { settingsManager.updateBothDirectionsStyle($0) }
            )) {
                Text("Separate Speeds").tag(BothDirectionsStyle.separateSpeeds)
                Text("Combined Arrows").tag(BothDirectionsStyle.combinedArrows)
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()

            if settingsManager.preferences.bothDirectionsStyle == .separateSpeeds {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Display download and upload speeds independently.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    previewContainer {
                        HStack(spacing: 8) {
                            Text("Preview:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Text("↓")
                                    .foregroundColor(Color(nsColor: MenuBarAppearance.downloadColor))
                                    .fontWeight(.semibold)
                                Text("2.45 MB/s")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                            }
                            Text("   ")
                            HStack(spacing: 4) {
                                Text("↑")
                                    .foregroundColor(Color(nsColor: MenuBarAppearance.uploadColor))
                                    .fontWeight(.semibold)
                                Text("120 KB/s")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Display both direction arrows with the speed of the currently dominant direction.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    previewContainer {
                        HStack(spacing: 8) {
                            Text("Preview:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Text("↓")
                                    .foregroundColor(Color(nsColor: MenuBarAppearance.downloadColor))
                                    .fontWeight(.semibold)
                                Text("↑")
                                    .foregroundColor(Color(nsColor: MenuBarAppearance.uploadColor))
                                    .fontWeight(.semibold)
                                Text("2.45 MB/s")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading, 4)
    }

    private var singleDirectionManualControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Direction")
                .font(.subheadline)
                .fontWeight(.medium)

            Picker("", selection: Binding(
                get: { settingsManager.preferences.manualDirection },
                set: { settingsManager.updateManualDirection($0) }
            )) {
                Text("Download").tag(NetworkDirection.download)
                Text("Upload").tag(NetworkDirection.upload)
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()

            if settingsManager.preferences.manualDirection == .download {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Continuously display download speed. Dominant direction switching will not override this.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    previewContainer {
                        HStack(spacing: 8) {
                            Text("Preview:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Text("↓")
                                    .foregroundColor(Color(nsColor: MenuBarAppearance.downloadColor))
                                    .fontWeight(.semibold)
                                Text("2.45 MB/s")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Continuously display upload speed. Dominant direction switching will not override this.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    previewContainer {
                        HStack(spacing: 8) {
                            Text("Preview:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Text("↑")
                                    .foregroundColor(Color(nsColor: MenuBarAppearance.uploadColor))
                                    .fontWeight(.semibold)
                                Text("120 KB/s")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading, 4)
    }

    private var singleDirectionAutomaticControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Automatically displays the direction currently carrying the dominant traffic using hysteresis switching.")
                .font(.caption)
                .foregroundColor(.secondary)

            previewContainer {
                HStack(spacing: 8) {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("↓")
                            .foregroundColor(Color(nsColor: MenuBarAppearance.downloadColor))
                            .fontWeight(.semibold)
                        Text("2.45 MB/s")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                    Text("(switches to ↑ when upload dominates)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.leading, 4)
    }

    private func previewContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack {
            content()
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }

    // MARK: - General Section (Launch at Login)

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("General")
                .font(.headline)

            HStack(spacing: 8) {
                Toggle("Launch at Login", isOn: Binding(
                    get: { settingsManager.loginItemManager.isEnabled },
                    set: { settingsManager.updateLaunchAtLogin($0) }
                ))
                .toggleStyle(.checkbox)
                .disabled(settingsManager.loginItemManager.isProcessing)

                if settingsManager.loginItemManager.isProcessing {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            Text("Automatically start ARRY Network Counter when you log in to macOS.")
                .font(.caption)
                .foregroundColor(.secondary)

            // Dynamic macOS SMAppService registration feedback
            switch settingsManager.loginItemManager.status {
            case .enabled:
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Registered with macOS login items")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            case .requiresApproval:
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("macOS requires user approval in System Settings")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    Button("Open Login Items Settings") {
                        settingsManager.loginItemManager.openSystemSettings()
                    }
                    .buttonStyle(.link)
                    .font(.caption2)
                }
            case .notFound:
                HStack(spacing: 5) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("Login item not registered with current environment")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            case .notRegistered:
                EmptyView()
            }

            if let errorMsg = settingsManager.loginItemManager.lastErrorMessage,
               settingsManager.loginItemManager.status != .requiresApproval {
                Text(errorMsg)
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Documentation Tab

    private var documentationTab: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Offline Documentation")
                        .font(.headline)

                    Text("All guides and legal disclosures are bundled locally and fully accessible without an internet connection.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 8) {
                    ForEach(DocumentationDocument.allCases) { doc in
                        docRow(document: doc)
                    }
                }

                Spacer(minLength: 10)
            }
            .padding(20)
        }
    }

    private func docRow(document: DocumentationDocument) -> some View {
        Button {
            settingsManager.viewingDocument = document
        } label: {
            HStack(spacing: 12) {
                Image(systemName: document.systemIcon)
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(document.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(document.subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        AboutView { doc in
            settingsManager.viewingDocument = doc
        }
    }

    // MARK: - Helpers

    private func loadLogoImage() -> NSImage? {
        if let direct = NSImage(named: "AppLogo") {
            return direct
        }

        if let url = Bundle.main.url(forResource: "AppLogo", withExtension: "png") {
            return NSImage(contentsOf: url)
        }

        if let url = Bundle.main.url(forResource: "AppLogo", withExtension: "png", subdirectory: "Assets.xcassets/AppLogo.imageset") {
            return NSImage(contentsOf: url)
        }

        let fileManager = FileManager.default
        let currentDir = fileManager.currentDirectoryPath
        let repoAssetPath = URL(fileURLWithPath: currentDir).appendingPathComponent("ARRYNetworkCounter/Resources/Assets.xcassets/AppLogo.imageset/AppLogo.png")
        if fileManager.fileExists(atPath: repoAssetPath.path) {
            return NSImage(contentsOf: repoAssetPath)
        }

        return NSApp.applicationIconImage
    }
}
