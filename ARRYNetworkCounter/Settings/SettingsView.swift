import SwiftUI
import AppKit

/// Native macOS Settings view providing compact, clean configuration of network display modes,
/// startup preferences, and documentation resources.
public struct SettingsView: View {
    @ObservedObject public var settingsManager: SettingsManager

    public init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                Divider()

                displaySection

                Divider()

                generalSection

                Divider()

                documentationSection

                Spacer(minLength: 10)
            }
            .padding(20)
        }
        .frame(minWidth: 430, idealWidth: 460, minHeight: 480, idealHeight: 520)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 14) {
            appLogoView
                .frame(width: 44, height: 44)

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
    private var appLogoView: some View {
        if let image = loadLogoImage() {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
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
        VStack(alignment: .leading, spacing: 8) {
            Text("General")
                .font(.headline)

            Toggle("Launch at Login", isOn: Binding(
                get: { settingsManager.preferences.launchAtLogin },
                set: { settingsManager.updateLaunchAtLogin($0) }
            ))
            .toggleStyle(.checkbox)

            Text("Automatically start ARRY Network Counter when you log in to macOS.")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("(Preference persisted. macOS system login-item registration will be activated in Phase 11)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Documentation Section

    private var documentationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Help & Resources")
                .font(.headline)

            VStack(spacing: 6) {
                docRow(
                    title: "User Guide & README",
                    subtitle: "Setup instructions, features, and usage guide",
                    icon: "book.pages",
                    file: "README.md"
                )

                docRow(
                    title: "Technical Architecture",
                    subtitle: "Subsystem designs, memory isolation, and performance rules",
                    icon: "cpu",
                    file: "Documentation/TECHNICAL_ARCHITECTURE.md"
                )

                docRow(
                    title: "Project Requirements",
                    subtitle: "Specifications, precision rules, and acceptance criteria",
                    icon: "checklist",
                    file: "Documentation/PROJECT_REQUIREMENTS.md"
                )

                docRow(
                    title: "Architecture Decisions (ADRs)",
                    subtitle: "Codified decisions for display modes, hysteresis, and storage",
                    icon: "doc.text",
                    file: "Documentation/PROJECT_DECISIONS.md"
                )
            }
        }
    }

    private func docRow(title: String, subtitle: String, icon: String, file: String) -> some View {
        Button {
            openDocument(file)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.forward.app")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        )
    }

    // MARK: - Helpers

    private func loadLogoImage() -> NSImage? {
        if let direct = NSImage(named: "AppLogo") {
            return direct
        }

        // Try bundle resources
        if let url = Bundle.main.url(forResource: "AppLogo", withExtension: "png") {
            return NSImage(contentsOf: url)
        }

        // Try subdirectory path in bundle
        if let url = Bundle.main.url(forResource: "AppLogo", withExtension: "png", subdirectory: "Assets.xcassets/AppLogo.imageset") {
            return NSImage(contentsOf: url)
        }

        // Try repository relative path
        let fileManager = FileManager.default
        let currentDir = fileManager.currentDirectoryPath
        let repoAssetPath = URL(fileURLWithPath: currentDir).appendingPathComponent("ARRYNetworkCounter/Resources/Assets.xcassets/AppLogo.imageset/AppLogo.png")
        if fileManager.fileExists(atPath: repoAssetPath.path) {
            return NSImage(contentsOf: repoAssetPath)
        }

        return NSApp.applicationIconImage
    }

    private func openDocument(_ relativePath: String) {
        let fileManager = FileManager.default
        let currentDir = fileManager.currentDirectoryPath

        // 1. Current working directory
        let localURL = URL(fileURLWithPath: currentDir).appendingPathComponent(relativePath)
        if fileManager.fileExists(atPath: localURL.path) {
            NSWorkspace.shared.open(localURL)
            return
        }

        // 2. Main bundle resources
        let filename = (relativePath as NSString).lastPathComponent
        if let bundleURL = Bundle.main.url(forResource: filename, withExtension: nil) {
            NSWorkspace.shared.open(bundleURL)
            return
        }

        // 3. Parent directory search
        var searchURL = Bundle.main.bundleURL
        for _ in 0..<5 {
            searchURL = searchURL.deletingLastPathComponent()
            let candidate = searchURL.appendingPathComponent(relativePath)
            if fileManager.fileExists(atPath: candidate.path) {
                NSWorkspace.shared.open(candidate)
                return
            }
        }
    }
}
