import Foundation

/// Comprehensive unit test suite for Phase 12 documentation, resource bundling,
/// offline accessibility, privacy audit verification, and About metadata.
public enum DocumentationTests {
    public static func run() throws -> Int {
        var count = 0
        let fileManager = FileManager.default
        let currentDir = fileManager.currentDirectoryPath
        let rootURL = URL(fileURLWithPath: currentDir)

        // ---------------------------------------------------------------------
        // Test 1: Verify all 4 Markdown documentation files exist in repo
        // ---------------------------------------------------------------------
        let setupURL = rootURL.appendingPathComponent("Documentation/UserGuides/SETUP_GUIDE.md")
        let usageURL = rootURL.appendingPathComponent("Documentation/UserGuides/USAGE_GUIDE.md")
        let termsURL = rootURL.appendingPathComponent("Documentation/Legal/TERMS_AND_CONDITIONS.md")
        let privacyURL = rootURL.appendingPathComponent("Documentation/Legal/PRIVACY_POLICY.md")

        assert(fileManager.fileExists(atPath: setupURL.path), "SETUP_GUIDE.md must exist in Documentation/UserGuides/")
        assert(fileManager.fileExists(atPath: usageURL.path), "USAGE_GUIDE.md must exist in Documentation/UserGuides/")
        assert(fileManager.fileExists(atPath: termsURL.path), "TERMS_AND_CONDITIONS.md must exist in Documentation/Legal/")
        assert(fileManager.fileExists(atPath: privacyURL.path), "PRIVACY_POLICY.md must exist in Documentation/Legal/")
        count += 1

        // ---------------------------------------------------------------------
        // Test 2: Setup Guide content verification
        // ---------------------------------------------------------------------
        let setupContent = try String(contentsOf: setupURL, encoding: .utf8)
        assert(setupContent.contains("macOS 13.0"), "Setup Guide must specify macOS 13.0 minimum requirement")
        assert(setupContent.contains("Apple Silicon") && setupContent.contains("Intel"), "Setup Guide must specify Apple Silicon and Intel support")
        assert(setupContent.contains("ARRY-Network-Counter.dmg"), "Setup Guide must explain DMG installation")
        assert(setupContent.contains("Gatekeeper"), "Setup Guide must explain Gatekeeper security approval")
        assert(setupContent.contains("ad-hoc") || setupContent.contains("unidentified developer"), "Setup Guide must explain current signing status accurately")
        assert(setupContent.contains("Open Anyway"), "Setup Guide must explain System Settings override")
        assert(setupContent.contains("LSUIElement") || setupContent.contains("Dock"), "Setup Guide must explain menu-bar accessory behavior")
        assert(setupContent.contains("SMAppService"), "Setup Guide must explain native login item registration")
        assert(!setupContent.contains("TODO") && !setupContent.contains("FIXME"), "Setup Guide must not contain placeholders")
        count += 1

        // ---------------------------------------------------------------------
        // Test 3: Usage Guide content verification
        // ---------------------------------------------------------------------
        let usageContent = try String(contentsOf: usageURL, encoding: .utf8)
        assert(usageContent.contains("getifaddrs"), "Usage Guide must explain kernel counter sampling")
        assert(usageContent.contains("Not an Internet Speed Test") || usageContent.contains("not perform artificial speed tests"), "Usage Guide must distinguish from synthetic speed tests")
        assert(usageContent.contains("Both Directions — Separate Speeds"), "Usage Guide must explain Separate Speeds mode")
        assert(usageContent.contains("Both Directions — Combined Arrows"), "Usage Guide must explain Combined Arrows mode")
        assert(usageContent.contains("Single Direction — Manual"), "Usage Guide must explain Manual direction mode")
        assert(usageContent.contains("Single Direction — Automatic"), "Usage Guide must explain Automatic direction mode")
        assert(usageContent.contains("10%") && usageContent.contains("10,000"), "Usage Guide must specify 10% relative margin and 10,000 B/s absolute threshold")
        assert(usageContent.contains("consecutive") && usageContent.contains("sample"), "Usage Guide must document consecutive sample confirmation")
        assert(usageContent.contains("Bytes per second") && usageContent.contains("bits per second"), "Usage Guide must clearly distinguish B/s from bps")
        assert(usageContent.contains("AirDrop") || usageContent.contains("LAN"), "Usage Guide must explain LAN traffic inclusion")
        assert(!usageContent.contains("TODO") && !usageContent.contains("FIXME"), "Usage Guide must not contain placeholders")
        count += 1

        // ---------------------------------------------------------------------
        // Test 4: Terms and Conditions content verification
        // ---------------------------------------------------------------------
        let termsContent = try String(contentsOf: termsURL, encoding: .utf8)
        assert(termsContent.contains("Acceptance of Terms"), "Terms must include acceptance of terms")
        assert(termsContent.contains("License and Permitted Use"), "Terms must include license grant")
        assert(termsContent.contains("Measurement Accuracy Limitations"), "Terms must include measurement accuracy limitations")
        assert(termsContent.contains("AS IS") || termsContent.contains("WITHOUT WARRANTY"), "Terms must include standard warranty disclaimers")
        assert(termsContent.contains("Limitation of Liability"), "Terms must include limitation of liability")
        assert(termsContent.contains("Apple Inc."), "Terms must include Apple trademark disclaimers")
        assert(termsContent.contains("ARRRY"), "Terms must specify ARRRY brand ownership")
        assert(!termsContent.contains("TODO") && !termsContent.contains("FIXME"), "Terms must not contain placeholders")
        count += 1

        // ---------------------------------------------------------------------
        // Test 5: Privacy Policy content & code audit verification
        // ---------------------------------------------------------------------
        let privacyContent = try String(contentsOf: privacyURL, encoding: .utf8)
        assert(privacyContent.contains("Zero outbound") || privacyContent.contains("zero outbound") || privacyContent.contains("zero outbound or inbound"), "Privacy Policy must state zero remote network transmission")
        assert(privacyContent.contains("Telemetry") || privacyContent.contains("analytics"), "Privacy Policy must document absence of telemetry/analytics")
        assert(privacyContent.contains("getifaddrs"), "Privacy Policy must document kernel byte counter processing")
        assert(privacyContent.contains("UserDefaults"), "Privacy Policy must document UserDefaults usage")
        assert(privacyContent.contains("displayMode"), "Privacy Policy must list displayMode key")
        assert(privacyContent.contains("bothDirectionsStyle"), "Privacy Policy must list bothDirectionsStyle key")
        assert(privacyContent.contains("manualDirection"), "Privacy Policy must list manualDirection key")
        assert(privacyContent.contains("launchAtLogin"), "Privacy Policy must list launchAtLogin key")
        assert(privacyContent.contains("defaults delete in.arrry.networkcounter"), "Privacy Policy must explain preference reset command")
        assert(!privacyContent.contains("TODO") && !privacyContent.contains("FIXME"), "Privacy Policy must not contain placeholders")
        count += 1

        // ---------------------------------------------------------------------
        // Test 6: DocumentationDocument Enum verification
        // ---------------------------------------------------------------------
        let allDocs = DocumentationDocument.allCases
        assert(allDocs.count == 4, "Must have exactly 4 documentation documents")
        for doc in allDocs {
            assert(!doc.title.isEmpty, "Document title must not be empty for \(doc.rawValue)")
            assert(!doc.subtitle.isEmpty, "Document subtitle must not be empty for \(doc.rawValue)")
            assert(!doc.systemIcon.isEmpty, "Document systemIcon must not be empty for \(doc.rawValue)")
            assert(doc.filename.hasSuffix(".md"), "Document filename must end with .md")
        }
        count += 1

        // ---------------------------------------------------------------------
        // Test 7: DocumentationLoader loads each document successfully
        // ---------------------------------------------------------------------
        for doc in allDocs {
            let loadedText = DocumentationLoader.loadDocument(doc)
            assert(!loadedText.isEmpty, "Loaded document text must not be empty for \(doc.rawValue)")
            assert(loadedText.contains("# "), "Loaded document text must contain markdown H1 header")
            assert(!loadedText.contains("Documentation resource not found"), "Document must be resolved without error: \(doc.rawValue)")
        }
        count += 1

        // ---------------------------------------------------------------------
        // Test 8: DocumentationLoader graceful fallback for missing document
        // ---------------------------------------------------------------------
        let missingContent = DocumentationLoader.loadDocument(.setupGuide, in: Bundle(path: NSTemporaryDirectory()) ?? Bundle.main)
        assert(!missingContent.isEmpty, "Fallback must return non-empty text")
        count += 1

        // ---------------------------------------------------------------------
        // Test 9: About section application metadata verification
        // ---------------------------------------------------------------------
        assert(AppConfiguration.appName == "ARRY Network Counter", "App name must be 'ARRY Network Counter'")
        assert(AppConfiguration.shortName == "ANC", "Short name must be 'ANC'")
        assert(AppConfiguration.organization == "ARRRY", "Organization must be 'ARRRY'")
        assert(!AppConfiguration.Version.versionString.isEmpty, "Version string must not be empty")
        assert(!AppConfiguration.Version.buildNumber.isEmpty, "Build number must not be empty")
        assert(AppConfiguration.Version.copyright.contains("ARRRY"), "Copyright must attribute ARRRY")
        count += 1

        // ---------------------------------------------------------------------
        // Test 10: SettingsTab navigation enum & bundled resource synchronization
        // ---------------------------------------------------------------------
        assert(SettingsTab.allCases.count == 3, "Must have 3 settings tabs")
        assert(SettingsTab.preferences.rawValue == "Preferences", "Tab 1 must be Preferences")
        assert(SettingsTab.documentation.rawValue == "Documentation", "Tab 2 must be Documentation")
        assert(SettingsTab.about.rawValue == "About", "Tab 3 must be About")

        // Verify resources in ARRYNetworkCounter/Resources/Documentation
        let bundledDocDir = rootURL.appendingPathComponent("ARRYNetworkCounter/Resources/Documentation")
        for doc in allDocs {
            let docFile = bundledDocDir.appendingPathComponent(doc.filename)
            assert(fileManager.fileExists(atPath: docFile.path), "Bundled resource file \(doc.filename) must exist in Resources/Documentation")
        }
        count += 1

        return count
    }
}
