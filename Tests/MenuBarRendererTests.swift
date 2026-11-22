import AppKit

/// Unit test suite for `MenuBarRenderer` and `MenuBarAppearance`.
public enum MenuBarRendererTests {
    public static func run() throws -> Int {
        var count = 0

        // Test 1: Both directions combined arrows with dominant download
        let content1 = MenuBarContent(
            displayMode: .bothDirections,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: "2.45 MB/s",
            uploadSpeedText: "120 KB/s",
            dominantDirection: .download,
            isConnected: true
        )
        let attr1 = MenuBarRenderer.render(content: content1)
        let plain1 = MenuBarRenderer.renderPlainText(content: content1)
        assert(plain1 == "↓ ↑ 2.45 MB/s", "Combined arrows with dominant download must render '↓ ↑ 2.45 MB/s', got '\(plain1)'")

        // Verify color attributes
        let str = attr1.string as NSString
        let downRange = str.range(of: "↓")
        let upRange = str.range(of: "↑")
        let speedRange = str.range(of: "2.45 MB/s")
        assert(downRange.location != NSNotFound, "Download arrow must exist")
        assert(upRange.location != NSNotFound, "Upload arrow must exist")
        assert(speedRange.location != NSNotFound, "Speed text must exist")

        let downColor = attr1.attribute(.foregroundColor, at: downRange.location, effectiveRange: nil) as? NSColor
        let upColor = attr1.attribute(.foregroundColor, at: upRange.location, effectiveRange: nil) as? NSColor
        assert(downColor == MenuBarAppearance.downloadColor, "Download arrow must have downloadColor")
        assert(upColor == MenuBarAppearance.uploadColor, "Upload arrow must have uploadColor")
        count += 1

        // Test 2: Both directions combined arrows with dominant upload
        let content2 = MenuBarContent(
            displayMode: .bothDirections,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: "50 KB/s",
            uploadSpeedText: "1.80 MB/s",
            dominantDirection: .upload,
            isConnected: true
        )
        let plain2 = MenuBarRenderer.renderPlainText(content: content2)
        assert(plain2 == "↓ ↑ 1.80 MB/s", "Combined arrows with dominant upload must render '↓ ↑ 1.80 MB/s', got '\(plain2)'")
        count += 1

        // Test 3: Both directions separate speeds
        let content3 = MenuBarContent(
            displayMode: .bothDirections,
            bothDirectionsStyle: .separateSpeeds,
            downloadSpeedText: "2.45 MB/s",
            uploadSpeedText: "120 KB/s",
            dominantDirection: .download,
            isConnected: true
        )
        let plain3 = MenuBarRenderer.renderPlainText(content: content3)
        assert(plain3 == "↓ 2.45 MB/s    ↑ 120 KB/s", "Separate speeds must render '↓ 2.45 MB/s    ↑ 120 KB/s', got '\(plain3)'")
        count += 1

        // Test 4: Single direction manual (download selected)
        let content4 = MenuBarContent(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: "500 KB/s",
            uploadSpeedText: "100 KB/s",
            dominantDirection: .upload, // dominant is upload, but manual mode ignores it!
            manualDirection: .download,
            isConnected: true
        )
        let plain4 = MenuBarRenderer.renderPlainText(content: content4)
        assert(plain4 == "↓ 500 KB/s", "Single direction manual download must render '↓ 500 KB/s', got '\(plain4)'")
        count += 1

        // Test 5: Single direction manual (upload selected)
        let content5 = MenuBarContent(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: "500 KB/s",
            uploadSpeedText: "100 KB/s",
            dominantDirection: .download,
            manualDirection: .upload,
            isConnected: true
        )
        let plain5 = MenuBarRenderer.renderPlainText(content: content5)
        assert(plain5 == "↑ 100 KB/s", "Single direction manual upload must render '↑ 100 KB/s', got '\(plain5)'")
        count += 1

        // Test 6: Single direction automatic (download dominant)
        let content6 = MenuBarContent(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: "10 MB/s",
            uploadSpeedText: "1 MB/s",
            dominantDirection: .download,
            isConnected: true
        )
        let plain6 = MenuBarRenderer.renderPlainText(content: content6)
        assert(plain6 == "↓ 10 MB/s", "Single direction automatic download must render '↓ 10 MB/s', got '\(plain6)'")
        count += 1

        // Test 7: Single direction automatic (upload dominant)
        let content7 = MenuBarContent(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: "100 KB/s",
            uploadSpeedText: "5 MB/s",
            dominantDirection: .upload,
            isConnected: true
        )
        let plain7 = MenuBarRenderer.renderPlainText(content: content7)
        assert(plain7 == "↑ 5 MB/s", "Single direction automatic upload must render '↑ 5 MB/s', got '\(plain7)'")
        count += 1

        // Test 8: Idle state fallback
        let content8 = MenuBarContent.idle
        let plain8 = MenuBarRenderer.renderPlainText(content: content8)
        assert(plain8 == "↓ ↑ 0 KB/s", "Idle default must render '↓ ↑ 0 KB/s', got '\(plain8)'")
        count += 1

        // Test 9: Disconnected state fallback
        let content9 = MenuBarContent.disconnected
        let plain9 = MenuBarRenderer.renderPlainText(content: content9)
        assert(plain9 == "↓ ↑ 0 KB/s", "Disconnected default must render '↓ ↑ 0 KB/s', got '\(plain9)'")
        count += 1

        // Test 10: Missing/nil speed strings fallback cleanly to 0 KB/s
        let content10 = MenuBarContent(
            displayMode: .bothDirections,
            bothDirectionsStyle: .combinedArrows,
            downloadSpeedText: nil,
            uploadSpeedText: nil,
            dominantDirection: .download,
            isConnected: false
        )
        let plain10 = MenuBarRenderer.renderPlainText(content: content10)
        assert(plain10 == "↓ ↑ 0 KB/s", "Nil speed texts must safely fallback to '↓ ↑ 0 KB/s', got '\(plain10)'")
        count += 1

        // Test 11: Both directions without arrows
        let content11 = MenuBarContent(
            displayMode: .bothDirections,
            bothDirectionsStyle: .withoutArrows,
            downloadSpeedText: "2.45 MB/s",
            uploadSpeedText: "120 KB/s",
            dominantDirection: .download,
            isConnected: true
        )
        let attr11 = MenuBarRenderer.render(content: content11)
        let plain11 = MenuBarRenderer.renderPlainText(content: content11)
        assert(plain11 == "DL 2.45 MB/s    UL 120 KB/s", "Both directions without arrows must render 'DL 2.45 MB/s    UL 120 KB/s', got '\(plain11)'")
        assert(!plain11.contains("↓") && !plain11.contains("↑"), "Without arrows must not contain arrow symbols")

        let str11 = attr11.string as NSString
        let dlRange = str11.range(of: "DL")
        let ulRange = str11.range(of: "UL")
        assert(dlRange.location != NSNotFound, "DL label must exist")
        assert(ulRange.location != NSNotFound, "UL label must exist")
        let dlColor = attr11.attribute(.foregroundColor, at: dlRange.location, effectiveRange: nil) as? NSColor
        let ulColor = attr11.attribute(.foregroundColor, at: ulRange.location, effectiveRange: nil) as? NSColor
        assert(dlColor == MenuBarAppearance.downloadColor, "DL label must have downloadColor")
        assert(ulColor == MenuBarAppearance.uploadColor, "UL label must have uploadColor")
        count += 1

        // Test 12: Single direction manual download without arrows
        let content12 = MenuBarContent(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .separateSpeeds,
            singleDirectionArrowStyle: .withoutArrows,
            downloadSpeedText: "2.45 MB/s",
            uploadSpeedText: "120 KB/s",
            dominantDirection: .upload,
            manualDirection: .download,
            isConnected: true
        )
        let plain12 = MenuBarRenderer.renderPlainText(content: content12)
        assert(plain12 == "2.45 MB/s", "Manual download without arrows must render '2.45 MB/s', got '\(plain12)'")
        assert(!plain12.contains("↓"), "Must not contain download arrow")
        count += 1

        // Test 13: Single direction manual upload without arrows
        let content13 = MenuBarContent(
            displayMode: .singleDirectionManual,
            bothDirectionsStyle: .separateSpeeds,
            singleDirectionArrowStyle: .withoutArrows,
            downloadSpeedText: "2.45 MB/s",
            uploadSpeedText: "120 KB/s",
            dominantDirection: .download,
            manualDirection: .upload,
            isConnected: true
        )
        let plain13 = MenuBarRenderer.renderPlainText(content: content13)
        assert(plain13 == "120 KB/s", "Manual upload without arrows must render '120 KB/s', got '\(plain13)'")
        assert(!plain13.contains("↑"), "Must not contain upload arrow")
        count += 1

        // Test 14: Single direction automatic download dominant without arrows
        let content14 = MenuBarContent(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .separateSpeeds,
            singleDirectionArrowStyle: .withoutArrows,
            downloadSpeedText: "10 MB/s",
            uploadSpeedText: "1 MB/s",
            dominantDirection: .download,
            isConnected: true
        )
        let plain14 = MenuBarRenderer.renderPlainText(content: content14)
        assert(plain14 == "10 MB/s", "Auto download dominant without arrows must render '10 MB/s', got '\(plain14)'")
        count += 1

        // Test 15: Single direction automatic upload dominant without arrows
        let content15 = MenuBarContent(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .separateSpeeds,
            singleDirectionArrowStyle: .withoutArrows,
            downloadSpeedText: "100 KB/s",
            uploadSpeedText: "5 MB/s",
            dominantDirection: .upload,
            isConnected: true
        )
        let plain15 = MenuBarRenderer.renderPlainText(content: content15)
        assert(plain15 == "5 MB/s", "Auto upload dominant without arrows must render '5 MB/s', got '\(plain15)'")
        count += 1

        // Test 16: Single direction automatic idle without arrows
        let content16 = MenuBarContent(
            displayMode: .singleDirectionAutomatic,
            bothDirectionsStyle: .separateSpeeds,
            singleDirectionArrowStyle: .withoutArrows,
            downloadSpeedText: "0 KB/s",
            uploadSpeedText: "0 KB/s",
            dominantDirection: .download,
            isConnected: true
        )
        let plain16 = MenuBarRenderer.renderPlainText(content: content16)
        assert(plain16 == "0 KB/s", "Auto idle without arrows must render '0 KB/s', got '\(plain16)'")
        count += 1

        return count
    }
}
