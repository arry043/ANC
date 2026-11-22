import SwiftUI
import AppKit

/// Native macOS About view presenting application identity, versioning, copyright,
/// and direct access to legal and operational documentation.
public struct AboutView: View {
    public let onSelectDocument: (DocumentationDocument) -> Void

    public init(onSelectDocument: @escaping (DocumentationDocument) -> Void) {
        self.onSelectDocument = onSelectDocument
    }

    public var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 10)

            // App Identity & Logo
            appLogoView
                .frame(width: 80, height: 80)

            VStack(spacing: 4) {
                Text(AppConfiguration.appName)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("(\(AppConfiguration.shortName))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Version \(AppConfiguration.Version.versionString) (Build \(AppConfiguration.Version.buildNumber))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }

            VStack(spacing: 6) {
                Text("Designed and engineered by \(AppConfiguration.organization)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("A lightweight, privacy-focused native macOS menu-bar utility for real-time network throughput monitoring.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Divider()
                .padding(.horizontal, 40)

            // Legal & Documentation Quick Access Buttons
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    Button("Terms & Conditions") {
                        onSelectDocument(.termsAndConditions)
                    }
                    .buttonStyle(.link)
                    .font(.caption)

                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption2)

                    Button("Privacy Policy") {
                        onSelectDocument(.privacyPolicy)
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }

                HStack(spacing: 16) {
                    Button("Setup Guide") {
                        onSelectDocument(.setupGuide)
                    }
                    .buttonStyle(.link)
                    .font(.caption)

                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption2)

                    Button("Usage Guide") {
                        onSelectDocument(.usageGuide)
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }

            Spacer(minLength: 10)

            // Copyright Information
            VStack(spacing: 2) {
                Text(AppConfiguration.Version.copyright)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("Universal Binary • macOS 13.0+")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Logo View

    @ViewBuilder
    private var appLogoView: some View {
        if let image = loadLogoImage() {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))

                Image(systemName: "network")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .padding(18)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }

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
