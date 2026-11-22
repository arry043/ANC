# ARRY Network Counter (ANC)
# PROJECT REQUIREMENTS

**Product Name:** ARRY Network Counter  
**Short Name:** ANC  
**Organization:** ARRRY  
**Platform:** macOS  
**Application Type:** Native macOS Menu Bar Utility  
**Distribution:** DMG Installer  
**Primary Language:** Swift  
**UI Framework:** SwiftUI + AppKit  
**Document Status:** Finalized Requirements  
**Version:** 1.0

---

# 1. Project Overview

ARRY Network Counter (ANC) is a lightweight native macOS utility that displays real-time network upload and download speeds directly in the macOS menu bar.

The application's primary purpose is to provide an immediate view of current network activity without requiring users to open a dashboard or monitoring application.

ANC will operate quietly in the background and display network speeds using configurable arrows and automatically formatted speed units.

The application will also provide a small Settings window where users can configure their preferred menu bar display mode and access setup instructions, usage documentation, terms and conditions, privacy information, and application details.

The application must remain simple, efficient, privacy-focused, and easy to install on multiple MacBooks.

# 2. Product Objectives

The primary objectives are:

1. Display current download speed in the macOS menu bar.
2. Display current upload speed in the macOS menu bar.
3. Provide multiple display modes.
4. Support automatic direction switching.
5. Automatically format network speeds into appropriate units.
6. Provide a minimal native macOS Settings window.
7. Provide application setup and usage documentation.
8. Distribute the application through a portable DMG installer.
9. Support Apple Silicon and Intel Macs where compatible.
10. Minimize CPU, memory, and battery consumption.

# 3. Application Scope

ANC will have only two primary interfaces:

## 3.1 Menu Bar Interface

The menu bar is the application's primary interface.

It must display the currently selected network-speed format continuously while ANC is running.

The application must not require users to open a separate dashboard to see network speeds.

## 3.2 Settings Window

The Settings window allows users to:

- Select a network display mode.
- Configure the display format for Both mode.
- Select a preferred direction in manual mode.
- Configure optional startup behavior.
- Access the Setup Guide.
- Access the Usage Guide.
- Read Terms and Conditions.
- Read the Privacy Policy.
- View application information and version.

No additional monitoring dashboard or history interface will be implemented.

# 4. Network Display Modes

ANC must support three primary display modes.

## 4.1 Mode A — Both Directions

This mode provides two display-format options.

### Option A1 — Separate Speeds

Display download and upload speeds independently.

Example:

    ↓ 2.45 MB/s    ↑ 120 KB/s

Requirements:

- Always display both arrows.
- Display download speed alongside the downward arrow.
- Display upload speed alongside the upward arrow.
- Update both values continuously.
- Use independent speed calculations for both directions.

### Option A2 — Combined Arrows with Switching Speed

Display both arrows but show only one numerical speed.

Example:

    ↓ ↑ 2.45 MB/s

Requirements:

- Always display both arrows.
- Display only one numerical speed.
- The numerical speed must represent the currently dominant traffic direction.
- When download traffic becomes dominant, display download speed.
- When upload traffic becomes dominant, display upload speed.
- Switch dynamically as traffic conditions change.
- Avoid rapid visual flickering through a small switching threshold or hysteresis.
- When both directions are idle, display:

      ↓ ↑ 0 KB/s

This option is intended for users who prefer a compact menu bar indicator.

### Option A3 — Without Arrows

Display download and upload speeds independently using compact text labels instead of directional arrows.

Example:

    DL 2.45 MB/s    UL 120 KB/s

Requirements:

- Do not display directional arrow glyphs (`↓` or `↑`).
- Display download speed alongside green `DL` label.
- Display upload speed alongside blue `UL` label.
- Update both values continuously.
- Preserve 4-space separation between download and upload speeds.

## 4.2 Mode B — Single Direction (Manual)

This mode displays only one selected direction, with optional arrow visibility.

Users must be able to select:

### Download
- With Arrow: `↓ 2.45 MB/s`
- Without Arrows: `2.45 MB/s`

### Upload
- With Arrow: `↑ 120 KB/s`
- Without Arrows: `120 KB/s`

Requirements:

- When arrows are enabled, display the corresponding directional arrow (`↓` or `↑`).
- When arrows are disabled, display only the numeric speed value without arrow glyphs.
- Only the selected direction's speed is displayed.
- The selected direction remains unchanged until the user changes the preference.
- The speed updates continuously.
- The non-selected direction is not displayed.

## 4.3 Mode C — Single Direction (Automatic)

This mode displays only the currently dominant traffic direction, with optional arrow visibility.

Examples:

Download is dominant:
- With Arrow: `↓ 2.45 MB/s`
- Without Arrows: `2.45 MB/s`

Upload is dominant:
- With Arrow: `↑ 120 KB/s`
- Without Arrows: `120 KB/s`

Requirements:

- When arrows are enabled, display only one arrow at a time matching the dominant direction.
- When arrows are disabled, display only the dominant speed value.
- Automatically determine the dominant traffic direction.
- Display the corresponding speed.
- Switch between upload and download as network activity changes.
- Use a small switching threshold to prevent flickering.
- When no meaningful network traffic exists, display:

      ↓ 0 KB/s

The default idle representation will use the download arrow.

# 5. Network Speed Monitoring

## 5.1 Required Metrics

ANC must calculate:

- Current download speed.
- Current upload speed.

Both measurements must be calculated independently.

## 5.2 Network Statistics

Use operating-system network-interface byte counters.

Required measurements:

- Total received bytes.
- Total transmitted bytes.
- Current network interface.
- Previous received-byte counter.
- Previous transmitted-byte counter.
- Actual elapsed sampling time.

## 5.3 Speed Calculation

Download speed:

    Download Bytes Per Second =
    (Current Received Bytes - Previous Received Bytes)
    / Elapsed Seconds

Upload speed:

    Upload Bytes Per Second =
    (Current Sent Bytes - Previous Sent Bytes)
    / Elapsed Seconds

The implementation must handle:

- Counter resets.
- Interface changes.
- Network disconnections.
- Network reconnections.
- Temporary zero traffic.
- Multiple available interfaces.
- Virtual and physical interface duplication.

The application must avoid double-counting traffic.

## 5.4 Sampling and Refresh

- Target menu bar refresh interval: approximately one second.
- Sampling must use actual elapsed monotonic time.
- Automatic direction switching must respond promptly to traffic changes.
- Network sampling must not depend on SwiftUI view rendering.
- The monitoring engine must continue working while the Settings window is closed.

# 6. Speed Unit Formatting

ANC must automatically select the appropriate unit based on the current traffic speed.

Supported units:

- KB/s
- MB/s
- GB/s
- TB/s

Use decimal conversion:

    1 KB/s = 1,000 bytes/s
    1 MB/s = 1,000 KB/s
    1 GB/s = 1,000 MB/s
    1 TB/s = 1,000 GB/s

Examples:

    450.25 KB/s
    2.45 MB/s
    1.25 GB/s
    1.20 TB/s

Requirements:

- Automatically change units when necessary.
- Use consistent decimal precision.
- Avoid unnecessary trailing zeros.
- Display zero traffic as 0 KB/s.
- Ensure readable menu bar text.
- Prevent excessively long numerical formatting.

The speed unit must represent bytes per second, not bits per second.

# 7. Menu Bar UI Requirements

The menu bar must remain minimal.

Requirements:

- Native macOS menu bar integration.
- Download arrow: downward arrow (↓).
- Upload arrow: upward arrow (↑).
- Download arrow color: green.
- Upload arrow color: blue.
- Readable numerical values.
- Compact horizontal layout.
- Live updates.
- No dashboard.
- No unnecessary animations.
- No additional monitoring widgets.

The application must adapt to available menu bar space as much as reasonably possible.

The application should use AppKit NSStatusItem for precise control over the displayed menu bar content.

# 8. Settings Window Requirements

ANC must provide a small native macOS Settings window.

The window must contain the following sections.

## 8.1 Network Display Settings

Allow users to configure:

- Both Directions.
- Single Direction (Manual).
- Single Direction (Automatic).

When Both Directions is selected, provide:

- Separate Speeds.
- Combined Arrows with Switching Speed.

When Single Direction (Manual) is selected, provide:

- Download.
- Upload.

The selected configuration must persist between application launches.

## 8.2 General Settings

Provide:

- Launch at Login: Enabled / Disabled.
- Speed Units: Automatic.
- Refresh Interval: Fixed default of approximately one second.

Do not introduce unnecessary configuration options.

## 8.3 Documentation and Help

Provide the following sections:

### Setup Guide

Explain:

1. Downloading ANC.dmg.
2. Opening the DMG installer.
3. Moving ANC.app into Applications.
4. Launching ANC.
5. Allowing the application to run when required by macOS security.
6. Opening Settings.
7. Configuring the preferred display mode.
8. Enabling launch at login if desired.

### Usage Guide

Explain:

- Both Directions — Separate Speeds.
- Both Directions — Combined Arrows with Switching Speed.
- Single Direction — Manual.
- Single Direction — Automatic.
- Understanding download and upload indicators.
- Understanding KB/s, MB/s, GB/s, and TB/s.

### Terms and Conditions

Provide a readable application terms document covering:

- Application usage.
- Software limitations.
- Network measurement accuracy.
- Third-party software and operating-system dependencies.
- Warranty disclaimer.
- Limitation of liability.
- Changes to application terms.

### Privacy Policy

Clearly communicate:

- No account registration.
- No user tracking.
- No analytics.
- No advertising.
- No cloud synchronization.
- No network traffic history collection.
- No external server dependency for ordinary monitoring.
- Network measurements are processed locally.

Only essential application preferences may be saved locally.

### About ANC

Display:

- Application name.
- Short name.
- Version.
- Organization: ARRRY.
- Copyright information.

# 9. Local Preferences and Persistence

ANC must not maintain a network history database.

The application may persist only essential user preferences.

Examples:

- Selected display mode.
- Selected Both display format.
- Selected manual direction.
- Launch-at-login preference.

Use lightweight local application preferences.

Network traffic measurements must remain in memory only.

No historical measurements should be written to persistent storage.

# 10. Explicitly Excluded Features

The following features are outside the scope of ANC.

- Internet speed testing.
- Speed-test servers.
- Network history.
- Historical traffic graphs.
- Daily or monthly traffic reports.
- Database storage.
- Cloud storage.
- User accounts.
- Authentication.
- Backend services.
- Analytics and telemetry.
- Advertising.
- Public IP lookup.
- Network diagnostic dashboard.
- Ping monitoring.
- Packet-loss monitoring.
- DNS diagnostics.
- Wi-Fi signal-strength monitoring.
- Unnecessary notifications.
- Multiple application dashboards.
- Subscription or payment systems.

Do not introduce these features without an explicit product requirement.

# 11. Application Architecture Requirements

ANC must be implemented as a native macOS application.

Required technologies:

| Component | Technology |
|---|---|
| Programming Language | Swift 6 |
| UI Framework | SwiftUI |
| Native Menu Bar Integration | AppKit NSStatusItem |
| Network Connectivity | Network.framework |
| Interface Statistics | System network-interface counters |
| Wi-Fi Information | Not required for initial release |
| Concurrency | Swift Concurrency |
| Local Preferences | UserDefaults |
| Build System | Xcode |
| Distribution | DMG |

The application must use a modular architecture.

Core responsibilities:

- Network monitoring.
- Speed calculation.
- Speed formatting.
- Interface detection.
- Display mode management.
- Menu bar rendering.
- Settings management.
- Documentation presentation.
- Application lifecycle management.

# 12. macOS Compatibility

The application must target macOS.

Preferred compatibility:

- Apple Silicon Macs.
- Intel Macs where supported.

Build a Universal Binary:

- arm64.
- x86_64.

The minimum supported macOS version must be selected during project setup based on API compatibility and the intended device support.

The application must not require Xcode, Swift, or external runtime installation on the destination Mac.

# 13. DMG Distribution Requirements

The application must be distributed as:

    ARRY-Network-Counter.dmg

The DMG must contain:

    ARRY Network Counter.app
    Applications shortcut

Installation workflow:

1. User opens the DMG.
2. User drags the application into Applications.
3. User ejects the DMG.
4. User launches ANC from Applications.

Distribution requirements:

- Standalone macOS application.
- Universal Binary.
- Proper application metadata.
- Application icon.
- Developer ID code signing for public distribution.
- Apple notarization.
- Stapled notarization ticket.
- Verified DMG installation.
- No additional runtime dependencies.

If Developer ID credentials are unavailable, a development or personal-use DMG may be generated separately, with its Gatekeeper limitations documented.

# 14. Performance Requirements

ANC must be designed as a lightweight background utility.

Requirements:

- Minimal CPU usage.
- Minimal memory consumption.
- Minimal battery impact.
- No unnecessary background tasks.
- No continuous external network requests.
- No excessive UI rendering.
- No unnecessary animations.
- No persistent network-statistics storage.

The monitoring engine must stop cleanly when the application terminates.

# 15. Privacy and Security Requirements

- No unnecessary permissions.
- No administrator privileges for ordinary monitoring.
- No collection or transmission of network measurements.
- No tracking or analytics.
- No embedded API keys or secrets.
- No external backend dependency.
- Secure application signing and distribution.

Any future external integration must be explicitly approved before implementation.

# 16. Testing and Acceptance Criteria

The application will be considered ready for its initial release when all the following requirements pass.

## Network Monitoring

- [ ] Download speed is calculated correctly.
- [ ] Upload speed is calculated correctly.
- [ ] Both directions work simultaneously.
- [ ] Zero traffic is handled correctly.
- [ ] Counter resets are handled.
- [ ] Network disconnection is handled.
- [ ] Network reconnection is handled.
- [ ] Interface changes are handled.
- [ ] Physical and virtual interfaces are not double-counted.

## Display Modes

- [ ] Both Directions — Separate Speeds.
- [ ] Both Directions — Combined Arrows with Switching Speed.
- [ ] Single Direction — Manual Download.
- [ ] Single Direction — Manual Upload.
- [ ] Single Direction — Automatic Switching.
- [ ] Idle traffic representation.
- [ ] Switching stability.

## Speed Formatting

- [ ] KB/s conversion.
- [ ] MB/s conversion.
- [ ] GB/s conversion.
- [ ] TB/s conversion.
- [ ] Decimal precision.
- [ ] Automatic unit transitions.

## Settings

- [ ] Settings window opens correctly.
- [ ] Display mode can be changed.
- [ ] Both display format can be changed.
- [ ] Manual direction can be changed.
- [ ] Preferences persist after restarting.
- [ ] Launch-at-login behavior works.
- [ ] Documentation sections are accessible.

## Distribution

- [ ] Application builds successfully.
- [ ] Universal Binary is verified.
- [ ] DMG is generated.
- [ ] Drag-and-drop installation works.
- [ ] Application launches from Applications.
- [ ] No development environment is required.
- [ ] Code signing is verified.
- [ ] Notarization is verified when credentials are available.

# 17. Final Product Definition

ARRY Network Counter is a minimal native macOS menu bar utility.

Its primary responsibility is to display current network download and upload speeds.

It supports three main display modes, with two display formats inside Both Directions mode.

The application includes one small Settings window for display configuration, startup preferences, setup instructions, usage documentation, terms and conditions, privacy information, and application details.

It does not include network history, a database, a dashboard, analytics, external services, or unnecessary functionality.

**Core Product Principle:**

Do one job, do it accurately, and do it with minimal resource consumption.

**Final Menu Bar Examples:**

Separate Speeds:

    ↓ 2.45 MB/s    ↑ 120 KB/s

Combined Arrows:

    ↓ ↑ 2.45 MB/s

Single Manual:

    ↓ 2.45 MB/s

Single Automatic:

    ↑ 120 KB/s

**ARRY Network Counter — Simple Network Monitoring for macOS.**