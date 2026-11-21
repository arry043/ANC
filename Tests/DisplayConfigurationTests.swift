import Foundation

/// Unit test suite for display configuration models: `DisplayMode`, `BothDirectionsStyle`, and `NetworkDirection`.
public enum DisplayConfigurationTests {
    public static func run() throws -> Int {
        var count = 0
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test 1: DisplayMode cases and count
        let displayModes = DisplayMode.allCases
        assert(displayModes.count == 3, "DisplayMode must have exactly 3 cases")
        assert(displayModes.contains(.bothDirections), "DisplayMode must include bothDirections")
        assert(displayModes.contains(.singleDirectionManual), "DisplayMode must include singleDirectionManual")
        assert(displayModes.contains(.singleDirectionAutomatic), "DisplayMode must include singleDirectionAutomatic")
        count += 1

        // Test 2: DisplayMode Codable & stable raw values
        for mode in DisplayMode.allCases {
            let data = try encoder.encode(mode)
            let decoded = try decoder.decode(DisplayMode.self, from: data)
            assert(decoded == mode, "Decoded DisplayMode must equal original")
            assert(mode.rawValue == mode.rawValue, "Raw value must be stable")
        }
        count += 1

        // Test 3: BothDirectionsStyle cases and Codable
        let bothStyles = BothDirectionsStyle.allCases
        assert(bothStyles.count == 2, "BothDirectionsStyle must have exactly 2 cases")
        assert(bothStyles.contains(.separateSpeeds), "Must contain separateSpeeds")
        assert(bothStyles.contains(.combinedArrows), "Must contain combinedArrows")
        for style in BothDirectionsStyle.allCases {
            let data = try encoder.encode(style)
            let decoded = try decoder.decode(BothDirectionsStyle.self, from: data)
            assert(decoded == style, "Decoded BothDirectionsStyle must equal original")
        }
        count += 1

        // Test 4: NetworkDirection cases and opposite helper
        let directions = NetworkDirection.allCases
        assert(directions.count == 2, "NetworkDirection must have exactly 2 cases")
        assert(NetworkDirection.download.opposite == .upload, "Opposite of download must be upload")
        assert(NetworkDirection.upload.opposite == .download, "Opposite of upload must be download")
        for dir in NetworkDirection.allCases {
            let data = try encoder.encode(dir)
            let decoded = try decoder.decode(NetworkDirection.self, from: data)
            assert(decoded == dir, "Decoded NetworkDirection must equal original")
        }
        count += 1

        return count
    }
}
