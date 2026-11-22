import Foundation

/// Identifier and metadata for user-facing, offline-accessible application documentation.
public enum DocumentationDocument: String, CaseIterable, Identifiable, Sendable {
    case setupGuide = "SETUP_GUIDE"
    case usageGuide = "USAGE_GUIDE"
    case termsAndConditions = "TERMS_AND_CONDITIONS"
    case privacyPolicy = "PRIVACY_POLICY"

    public var id: String { rawValue }

    /// Document filename on disk (e.g. `SETUP_GUIDE.md`).
    public var filename: String {
        "\(rawValue).md"
    }

    /// User-facing document title.
    public var title: String {
        switch self {
        case .setupGuide:
            return "Setup & Installation Guide"
        case .usageGuide:
            return "User & Operations Guide"
        case .termsAndConditions:
            return "Terms and Conditions"
        case .privacyPolicy:
            return "Privacy Policy"
        }
    }

    /// Short descriptive subtitle.
    public var subtitle: String {
        switch self {
        case .setupGuide:
            return "System requirements, DMG install, Gatekeeper, and login items"
        case .usageGuide:
            return "Display modes, direction switching, SI units, and limitations"
        case .termsAndConditions:
            return "Software license, permitted usage, disclaimers, and warranty"
        case .privacyPolicy:
            return "Local storage, kernel counters, and zero-telemetry audit"
        }
    }

    /// Associated SF Symbol icon for native macOS presentation.
    public var systemIcon: String {
        switch self {
        case .setupGuide:
            return "gearshape.arrow.triangle.2.circlepath"
        case .usageGuide:
            return "book.closed"
        case .termsAndConditions:
            return "doc.text"
        case .privacyPolicy:
            return "hand.raised.shield"
        }
    }
}

/// Utility provider responsible for locating and reading offline markdown documentation.
public final class DocumentationLoader: Sendable {
    public init() {}

    /// Locates the file URL for a given documentation document.
    ///
    /// Searches bundled application resources first, followed by local filesystem paths
    /// to support command-line and test environments.
    ///
    /// - Parameters:
    ///   - document: The requested document.
    ///   - bundle: The bundle to search (defaults to `Bundle.main`).
    /// - Returns: The file URL if found, or `nil`.
    public static func url(for document: DocumentationDocument, in bundle: Bundle = .main) -> URL? {
        let fileManager = FileManager.default

        // 1. Bundle subdirectory "Documentation" (with extension)
        if let url = bundle.url(forResource: document.rawValue, withExtension: "md", subdirectory: "Documentation"),
           fileManager.fileExists(atPath: url.path) {
            return url
        }

        // 2. Bundle subdirectory "Documentation" (full filename)
        if let url = bundle.url(forResource: document.filename, withExtension: nil, subdirectory: "Documentation"),
           fileManager.fileExists(atPath: url.path) {
            return url
        }

        // 3. Direct bundle resource URL
        if let resourceURL = bundle.resourceURL {
            let docURL = resourceURL.appendingPathComponent("Documentation").appendingPathComponent(document.filename)
            if fileManager.fileExists(atPath: docURL.path) {
                return docURL
            }
            let flatURL = resourceURL.appendingPathComponent(document.filename)
            if fileManager.fileExists(atPath: flatURL.path) {
                return flatURL
            }
        }

        // 4. Bundle root (with or without extension)
        if let url = bundle.url(forResource: document.rawValue, withExtension: "md"),
           fileManager.fileExists(atPath: url.path) {
            return url
        }
        if let url = bundle.url(forResource: document.filename, withExtension: nil),
           fileManager.fileExists(atPath: url.path) {
            return url
        }

        // 5. Local filesystem paths (for test runner / repository execution)
        let candidateRelativePaths = [
            "Documentation/UserGuides/\(document.filename)",
            "Documentation/Legal/\(document.filename)",
            "Documentation/\(document.filename)"
        ]

        let currentDir = fileManager.currentDirectoryPath
        let currentURL = URL(fileURLWithPath: currentDir)

        for relPath in candidateRelativePaths {
            let candidate = currentURL.appendingPathComponent(relPath)
            if fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
        }

        // 6. Search upwards from current directory or bundle location
        var searchDir = bundle.bundleURL
        for _ in 0..<5 {
            searchDir = searchDir.deletingLastPathComponent()
            for relPath in candidateRelativePaths {
                let candidate = searchDir.appendingPathComponent(relPath)
                if fileManager.fileExists(atPath: candidate.path) {
                    return candidate
                }
            }
        }

        return nil
    }

    /// Loads the UTF-8 text content of a documentation document.
    ///
    /// - Parameters:
    ///   - document: The requested document.
    ///   - bundle: The bundle to search (defaults to `Bundle.main`).
    /// - Returns: The markdown text content, or a graceful error message if missing.
    public static func loadDocument(_ document: DocumentationDocument, in bundle: Bundle = .main) -> String {
        guard let fileURL = url(for: document, in: bundle) else {
            return """
            # \(document.title)

            *Documentation resource not found.*

            The document `\(document.filename)` could not be located in the application bundle or local filesystem. Please verify that the application resources were copied correctly during build.
            """
        }

        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return """
            # \(document.title)

            *Error reading document.*

            Failed to read `\(document.filename)`: \(error.localizedDescription)
            """
        }
    }
}
