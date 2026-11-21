import Foundation

/// Unit test suite for `AppPreferences`.
public enum AppPreferencesTests {
    public static func run() throws -> Int {
        var count = 0
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test 1: Approved default preferences
        let defaults = AppPreferences.default
        assert(defaults.displayMode == .bothDirections, "Default displayMode must be bothDirections")
        assert(defaults.bothDirectionsStyle == .separateSpeeds, "Default bothDirectionsStyle must be separateSpeeds")
        assert(defaults.manualDirection == .download, "Default manualDirection must be download")
        assert(defaults.launchAtLogin == false, "Default launchAtLogin must be false per ADR-022")
        count += 1

        // Test 2: Custom preferences initialization
        let custom = AppPreferences(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            manualDirection: .upload,
            launchAtLogin: true
        )
        assert(custom.displayMode == .singleDirectionAutomatic, "Custom displayMode must match")
        assert(custom.bothDirectionsStyle == .combinedArrows, "Custom bothDirectionsStyle must match")
        assert(custom.manualDirection == .upload, "Custom manualDirection must match")
        assert(custom.launchAtLogin == true, "Custom launchAtLogin must match")
        assert(custom != defaults, "Custom preferences must not equal defaults")
        count += 1

        // Test 3: Codable round-trip encoding and decoding
        let encodedData = try encoder.encode(custom)
        let decoded = try decoder.decode(AppPreferences.self, from: encodedData)
        assert(decoded == custom, "Decoded preferences must equal original preferences")
        assert(decoded.displayMode == .singleDirectionAutomatic, "Decoded displayMode must match")
        assert(decoded.launchAtLogin == true, "Decoded launchAtLogin must match")
        count += 1

        return count
    }
}
