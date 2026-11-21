# PROJECT_DECISIONS.md

# ARRY Network Counter (ANC)

**Organization:** ARRRY  
**Application:** ARRY Network Counter  
**Short Name:** ANC  
**Platform:** macOS  
**Document Type:** Architecture Decision Record (ADR) Register  
**Status:** Active  
**Last Updated:** 2026-11-21

---

## 1. Purpose

This document records the important product, technical, architectural, and distribution decisions made during the development of ARRY Network Counter.

Its purpose is to ensure:

- Consistency throughout development.
- Clear reasoning behind technical choices.
- Prevention of unnecessary architecture changes.
- A documented history of approved decisions.
- Alignment between requirements, architecture, and implementation.
- A reliable reference for developers and AI coding agents.

Every significant decision must be documented before changing the implementation.

---

## 2. Decision Management Rules

### Decision Status

| Status | Meaning |
|---|---|
| Accepted | Decision is approved and should be followed |
| Proposed | Awaiting approval |
| Superseded | Replaced by a newer decision |
| Rejected | Considered but not approved |
| Deprecated | No longer recommended |

### Decision Rules

1. Do not silently change an accepted decision.
2. Record significant architectural changes in this document.
3. Include the reason behind each decision.
4. Reference the affected project documents.
5. When a decision changes, mark the previous decision as Superseded.
6. Never delete historical decisions.
7. Update `TECHNICAL_ARCHITECTURE.md` when an architectural decision changes.
8. Update `PROJECT_REQUIREMENTS.md` when product scope or behavior changes.
9. Update `IMPLEMENTATION_PHASES.md` when the development sequence changes.
10. Update `CURRENT_STATUS.md` when implementation progress or blockers change.

---

# 3. Product Decisions

## ADR-001 — Native macOS Application

**Status:** Accepted  
**Category:** Product / Platform

### Decision

ANC will be developed as a native macOS application using Swift.

### Reasoning

- Native macOS integration.
- Better menu bar integration.
- Lower overhead than web-based desktop frameworks.
- Direct access to Apple's system frameworks.
- No embedded browser runtime.
- Better alignment with macOS user experience.

### Alternatives Considered

- Electron.
- Tauri.
- Flutter.
- Web-based desktop application.

### Final Outcome

Use native Swift development with SwiftUI and AppKit.

---

## ADR-002 — Menu Bar Only Primary Interface

**Status:** Accepted  
**Category:** Product / UI

### Decision

The macOS menu bar will be the application's primary interface.

### Reasoning

ANC exists to display current network speeds without requiring users to open a window.

### Requirements

- Show current download/upload speeds.
- Keep the display compact.
- Support dynamic updates.
- Avoid unnecessary UI elements.
- Provide access to Settings and Quit.

### Rejected Alternatives

- Dashboard.
- Full application home screen.
- Monitoring popover.
- Charts and reports.

### Final Outcome

Use an AppKit `NSStatusItem` for the primary display.

---

## ADR-003 — Three Main Display Modes

**Status:** Accepted  
**Category:** Product / Functionality

### Decision

ANC will support three primary display modes.

1. Both Directions.
2. Single Direction — Manual.
3. Single Direction — Automatic.

Both Directions will include:

- Separate Speeds.
- Combined Arrows with Switching Speed.

### Reasoning

These options provide flexibility without making the application unnecessarily complicated.

### Final Outcome

Implement all specified display modes without introducing additional modes.

---

## ADR-004 — Combined Arrows with Dominant Speed

**Status:** Accepted  
**Category:** Product / Display Behavior

### Decision

In Combined Arrows mode, both download and upload arrows must always remain visible, while only one numerical speed is displayed.

The numerical speed represents the currently dominant direction.

### Example

Download dominant:

```text
↓ ↑ 2.45 MB/s
```

Upload dominant:

```text
↓ ↑ 1.80 MB/s
```

Idle:

```text
↓ ↑ 0 KB/s
```

### Reasoning

The user can see both directions while maintaining a compact menu bar display.

### Final Outcome

Use the shared dominant direction engine to select the numerical speed.

---

## ADR-005 — Manual Direction Selection

**Status:** Accepted  
**Category:** Product / Display Behavior

### Decision

Manual mode must allow users to choose Download or Upload.

The selected direction remains active until the user changes it.

### Final Outcome

The non-selected direction must not appear in the menu bar.

---

## ADR-006 — Automatic Direction Selection

**Status:** Accepted  
**Category:** Product / Display Behavior

### Decision

Automatic mode displays only the direction currently carrying the dominant traffic rate.

### Behavior

- Download dominant: show download arrow and speed.
- Upload dominant: show upload arrow and speed.
- Idle: show download arrow and `0 KB/s`.

### Reasoning

The display should adapt to changing traffic without requiring manual interaction.

### Final Outcome

Use the same dominant direction engine as Combined Arrows mode.

---

## ADR-007 — Direction Switching Hysteresis

**Status:** Accepted  
**Category:** Product / Algorithm

### Decision

Automatic direction switching must use hysteresis to prevent unnecessary visual flickering.

### Initial Parameters

- Approximately 10% relative switching margin.
- Small absolute noise threshold.
- Two consecutive valid sample confirmations.
- Download as the default idle direction.

### Reasoning

Download and upload rates can fluctuate rapidly. Switching on every small difference creates an unstable menu bar display.

### Final Outcome

Centralize switching parameters in `DominantDirectionEngine` and validate them through testing.

---

## ADR-008 — Minimal Product Scope

**Status:** Accepted  
**Category:** Product / Scope

### Decision

ANC will remain a minimal real-time network speed indicator.

### Explicitly Excluded

- Network speed tests.
- Network history.
- Traffic reports.
- Charts.
- Public IP lookup.
- Ping monitoring.
- Packet loss monitoring.
- DNS diagnostics.
- Wi-Fi signal monitoring.
- Network diagnostics dashboard.
- Accounts.
- Cloud synchronization.
- Analytics.
- Advertisements.
- Backend services.

### Reasoning

These features are outside the application's primary purpose.

### Final Outcome

Do not introduce excluded features without an explicit requirements change.

---

# 4. Technical Architecture Decisions

## ADR-009 — Swift 6

**Status:** Accepted  
**Category:** Technology

### Decision

Use Swift 6 as the primary programming language.

### Reasoning

- Native Apple ecosystem support.
- Modern concurrency.
- Strong type safety.
- Native system API integration.
- Suitable for lightweight macOS applications.

### Final Outcome

All application logic will be written in Swift.

---

## ADR-010 — SwiftUI and AppKit Together

**Status:** Accepted  
**Category:** UI Architecture

### Decision

Use SwiftUI for Settings and documentation views, and AppKit for menu bar integration.

### Reasoning

SwiftUI provides a convenient native settings interface, while AppKit provides precise control over status items.

### Final Outcome

- SwiftUI: Settings and documentation.
- AppKit: `NSStatusItem` and menu bar rendering.

---

## ADR-011 — Network.framework for Path Detection

**Status:** Accepted  
**Category:** Networking

### Decision

Use Apple's `Network.framework` and `NWPathMonitor` to monitor network path changes.

### Responsibilities

- Detect connectivity changes.
- Identify available network interface types.
- Detect path transitions.
- Trigger interface re-evaluation.

### Important Clarification

`NWPathMonitor` is not the source of download/upload byte counters.

### Final Outcome

Use it for network path awareness only.

---

## ADR-012 — System Interface Byte Counters

**Status:** Accepted  
**Category:** Networking

### Decision

Use native macOS network interface statistics for traffic measurements.

### Proposed Implementation

- `getifaddrs()`.
- `AF_LINK` interface records.
- `struct if_data`.
- `ifi_ibytes`.
- `ifi_obytes`.

### Reasoning

The application needs actual system-level received and transmitted byte counters.

### Final Outcome

Calculate speed from consecutive system counter snapshots.

The implementation must verify the availability and correctness of these counters on the selected macOS deployment target.

---

## ADR-013 — Avoid Blind Interface Aggregation

**Status:** Accepted  
**Category:** Networking

### Decision

Do not blindly sum the byte counters of every available network interface.

### Reasoning

macOS can expose physical, virtual, loopback, tunnel, and bridge interfaces.

Some interfaces may represent overlapping traffic.

Summing everything can result in double-counting.

### Final Outcome

Select the relevant interface based on the active network path and validated interface information.

VPN and virtual interface behavior must be explicitly tested.

---

## ADR-014 — Byte-per-Second Measurement

**Status:** Accepted  
**Category:** Calculation

### Decision

ANC measures and displays bytes per second rather than bits per second.

### Formula

```text
Speed = Byte Counter Difference / Actual Elapsed Time
```

### Supported Units

- KB/s.
- MB/s.
- GB/s.
- TB/s.

### Conversion Standard

Decimal base 1000.

### Final Outcome

Do not display Mbps, Gbps, or other bit-based speed units.

---

## ADR-015 — Actual Elapsed Sampling Time

**Status:** Accepted  
**Category:** Calculation

### Decision

Use actual elapsed time between network snapshots.

### Reasoning

Sampling operations are not guaranteed to execute at exact one-second intervals.

### Final Outcome

Use a monotonic clock, such as Swift's `ContinuousClock`.

Do not calculate speed using an assumed fixed interval.

---

## ADR-016 — In-Memory Network Measurements

**Status:** Accepted  
**Category:** Storage / Privacy

### Decision

Network measurements must remain in memory.

### Allowed Runtime Data

- Previous byte counters.
- Current byte counters.
- Previous sample timestamp.
- Current speeds.
- Current interface information.
- Direction-selection state.

### Prohibited Storage

- Historical network speeds.
- Traffic logs.
- Persistent byte-counter snapshots.
- Network usage reports.

### Final Outcome

Discard temporary monitoring data when no longer needed and when the application terminates.

---

## ADR-017 — UserDefaults for Preferences

**Status:** Accepted  
**Category:** Storage

### Decision

Use `UserDefaults` for essential application preferences.

### Approved Preferences

- Display mode.
- Both Directions display style.
- Manual direction.
- Launch at Login preference.

### Reasoning

A database is unnecessary for a small collection of local settings.

### Final Outcome

No SwiftData, Core Data, SQLite, or remote database.

---

## ADR-018 — Swift Concurrency

**Status:** Accepted  
**Category:** Concurrency

### Decision

Use Swift Concurrency for asynchronous monitoring and application coordination.

### Requirements

- Cancellable monitoring tasks.
- Safe shared-state access.
- Main-actor UI updates.
- No duplicate sampling loops.
- Clean shutdown.
- No blocking network operations on the main thread.

### Final Outcome

Use appropriate actors, tasks, and `MainActor` isolation.

---

## ADR-019 — Native Menu Bar Rendering

**Status:** Accepted  
**Category:** UI Architecture

### Decision

Use AppKit's `NSStatusItem` for the menu bar indicator.

### Reasoning

The application needs precise control over text, arrows, spacing, colors, and updates.

### Final Outcome

The status item will render the current speed without requiring a separate dashboard or open window.

---

## ADR-020 — Minimal Settings Window

**Status:** Accepted  
**Category:** UI / Settings

### Decision

Provide one compact Settings window.

### Sections

1. Network Display.
2. General.
3. Help & Documentation.
4. About ANC.

### Final Outcome

No separate dashboard, analytics window, or advanced monitoring interface.

---

# 5. macOS Integration Decisions

## ADR-021 — Menu Bar Application Without a Normal Dock Icon

**Status:** Accepted  
**Category:** macOS Integration

### Decision

ANC should run as a menu bar utility without displaying a normal Dock icon during regular operation.

### Proposed Configuration

Use `LSUIElement = YES` or an equivalent supported activation policy.

### Final Outcome

Settings must remain accessible even when the normal Dock icon is hidden.

---

## ADR-022 — Optional Launch at Login

**Status:** Accepted  
**Category:** macOS Integration

### Decision

Provide an optional Launch at Login setting.

### Proposed Technology

Apple's `ServiceManagement` framework and `SMAppService` where supported by the deployment target.

### Behavior

- Disabled by default.
- User can enable or disable it.
- Registration errors must be handled.
- Application must work normally without it.

---

## ADR-023 — No Administrator Privileges for Normal Monitoring

**Status:** Accepted  
**Category:** Permissions

### Decision

Basic network speed monitoring should not require administrator privileges.

### Final Outcome

Use available system interface statistics without requesting unnecessary elevated privileges.

---

## ADR-024 — Minimum Necessary Permissions

**Status:** Accepted  
**Category:** Security

### Decision

Do not request unrelated macOS permissions.

### Not Required for Normal Operation

- Full Disk Access.
- Accessibility.
- Screen Recording.
- Location Services.
- Contacts.
- Camera.
- Microphone.

### Final Outcome

Request only permissions genuinely required by an approved future feature. No such additional permissions are currently expected.

---

# 6. Distribution Decisions

## ADR-025 — DMG Distribution

**Status:** Accepted  
**Category:** Distribution

### Decision

Distribute ANC through a macOS DMG installer.

### Expected Filename

```text
ARRY-Network-Counter.dmg
```

### Installation Experience

1. Open the DMG.
2. Drag the application into Applications.
3. Eject the DMG.
4. Launch ANC from Applications.

### Final Outcome

The destination Mac must not require Xcode or a Swift development environment.

---

## ADR-026 — Universal Binary

**Status:** Accepted  
**Category:** Distribution / Compatibility

### Decision

Target a Universal Binary containing:

- `arm64` — Apple Silicon.
- `x86_64` — Intel.

### Reasoning

The application should support both major Mac processor architectures.

### Final Outcome

Build and verify both architecture slices before release.

---

## ADR-027 — Developer ID Signing and Notarization

**Status:** Accepted  
**Category:** Distribution / Security

### Decision

Prefer Developer ID code signing and Apple notarization for public distribution.

### Requirements

- Developer ID Application certificate.
- Appropriate signing configuration.
- Hardened runtime where required.
- Apple notarization.
- Stapled notarization ticket.

### Reasoning

This provides a more frictionless installation experience and improves trust for users downloading the application.

### Dependency

Developer ID distribution and notarization generally require paid Apple Developer Program membership.

### Final Outcome

If signing credentials are unavailable, produce a clearly identified personal-testing DMG without claiming it is notarized.

---

# 7. Privacy Decisions

## ADR-028 — No Backend or External Service

**Status:** Accepted  
**Category:** Privacy / Architecture

### Decision

ANC must work independently without external infrastructure.

### Excluded Infrastructure

- Backend APIs.
- Cloud databases.
- Authentication services.
- Remote monitoring services.
- Analytics platforms.
- Cloud synchronization.

### Final Outcome

All normal monitoring and speed calculations happen locally.

---

## ADR-029 — No Analytics or Tracking

**Status:** Accepted  
**Category:** Privacy

### Decision

Do not include analytics, telemetry, advertisements, tracking pixels, or user behavior monitoring.

### Reasoning

The application does not require these services to perform its purpose.

### Final Outcome

No tracking SDKs or advertising dependencies.

---

## ADR-030 — Offline Documentation

**Status:** Accepted  
**Category:** Documentation

### Decision

Bundle application documentation inside the application.

### Required Documents

- Setup Guide.
- Usage Guide.
- Terms and Conditions.
- Privacy Policy.
- About ANC.

### Final Outcome

Documentation must remain accessible without an internet connection.

---

# 8. Performance Decisions

## ADR-031 — Approximately One-Second Display Refresh

**Status:** Accepted  
**Category:** Performance

### Decision

The menu bar display should refresh approximately once per second.

### Reasoning

This provides useful real-time visibility without unnecessary UI updates.

### Final Outcome

Sampling and rendering intervals should be independently managed.

The internal sampling frequency may be adjusted to support responsive automatic direction switching.

---

## ADR-032 — No Unnecessary Persistent Processes

**Status:** Accepted  
**Category:** Performance / Lifecycle

### Decision

ANC should not leave a separate monitoring process running after the application is terminated.

### Final Outcome

All application-owned sampling tasks and monitoring resources must stop on termination.

Optional Launch at Login only starts the application when the user signs in; it does not create a separate monitoring daemon.

---

## ADR-033 — Counter Discontinuity and Rollover Policy

**Status:** Accepted  
**Category:** Calculation / Networking

### Context

In macOS Darwin BSD network interface statistics (`getifaddrs()`), link-layer byte counters (`struct if_data`) provide 32-bit cumulative counters (`ifi_ibytes` and `ifi_obytes`). When a counter decreases between consecutive samples, two possibilities exist:
1. A legitimate 32-bit unsigned counter wraparound (exceeding ~4.29 GB).
2. An interface reset, reboot, driver re-initialization, or network stack flush where the counter restarts from zero.

Without kernel-level sequence numbers or 64-bit hardware registers exposed through `getifaddrs()`, distinguishing a legitimate wraparound from an interface counter reset is inherently ambiguous. If an interface resets from 100 KB down to 0, treating the decrease as a 32-bit wraparound would calculate a false speed spike of ~4.29 GB/s.

### Decision

Any unexpected counter decrease ($C_t < C_{t-1}$) is treated as a counter discontinuity:
1. Underflow is prevented by detecting the decrease before subtraction.
2. The current sample establishes a fresh calculation baseline.
3. The interval returns a baseline reset result (`.baselineReset(reason: .counterDecreased)`).
4. No speed measurement is emitted for that interval.
5. Normal speed calculation resumes on the subsequent valid sample.

### Reasoning

- Preserves the core principle: "Never fabricate or estimate speed values."
- Eliminates multi-gigabyte false throughput spikes caused by network interface resets.
- At typical 1-second sampling intervals, an unmeasured single-second discontinuity is vastly preferable to displaying a catastrophic 4.29 GB/s false spike in the macOS menu bar.

---

# 9. Decisions Pending Implementation Validation

The following decisions are accepted at the product or architectural level but require implementation-time verification.

| ID | Topic | Validation Required |
|---|---|---|
| P-001 | Minimum macOS version | Confirm API availability and compatibility |
| P-002 | Interface selection | Validate Wi-Fi, Ethernet, VPN, and virtual interfaces |
| P-003 | Counter retrieval | Verify `getifaddrs()` counter behavior on supported macOS versions |
| P-004 | Hysteresis parameters | Tune thresholds through real traffic testing |
| P-005 | Internal sampling frequency | Validate responsiveness and resource consumption |
| P-006 | App Sandbox | Verify compatibility with the chosen counter access and distribution configuration |
| P-007 | Universal Binary | Verify both architecture slices and deployment compatibility |
| P-008 | Login registration | Verify `SMAppService` behavior on supported macOS versions |

These items are not permission to change the product scope. They are implementation validation tasks.

---

# 10. Rejected Decisions & Alternatives

The following alternatives have been considered and rejected for the current product.

| Alternative | Decision | Reason |
|---|---|---|
| Electron | Rejected | Unnecessary runtime overhead |
| Tauri | Rejected | Native Swift is preferred |
| Flutter | Rejected | Unnecessary framework |
| Backend API | Rejected | No server-side functionality needed |
| Database | Rejected | No persistent monitoring history |
| SwiftData | Rejected | Preferences do not justify a database |
| Speed Test API | Rejected | Not part of product requirements |
| Analytics SDK | Rejected | Not needed |
| Dashboard | Rejected | Violates minimal interface objective |
| Charts and History | Rejected | Outside scope |
| Bit-based Speed Display | Rejected | Byte-based display selected |

A rejected alternative may only be reconsidered through an explicit requirements and architecture review.

---

# 11. Decision Change History

Record every change to an accepted decision here.

| Date | Decision ID | Change | Reason | Status |
|---|---|---|---|---|
| 2026-11-21 | Initial ADR Register | Established project decisions ADR-001 to ADR-032 | Initial architecture definition | Accepted |

Future entries must include:

- Date.
- Original decision ID.
- Previous decision.
- New decision.
- Reason for change.
- Affected documents.
- Approval status.

---

# 12. AI Agent Development Instructions

Any AI coding agent working on ANC must follow these instructions.

### Before Implementation

1. Read `PROJECT_REQUIREMENTS.md`.
2. Read `TECHNICAL_ARCHITECTURE.md`.
3. Read `IMPLEMENTATION_PHASES.md`.
4. Read `PROJECT_DECISIONS.md`.
5. Read `CURRENT_STATUS.md`.
6. Identify the current active phase.
7. Review existing code before changing anything.

### During Implementation

- Follow accepted decisions.
- Respect the defined product scope.
- Do not introduce unnecessary dependencies.
- Do not create backend services.
- Do not introduce databases.
- Do not add excluded features.
- Do not replace native macOS APIs with unnecessary third-party alternatives.
- Do not mark unverified functionality as completed.
- Do not skip required tests.
- Preserve existing working functionality.

### After Implementation

1. Run relevant tests.
2. Verify the actual implementation.
3. Update `CURRENT_STATUS.md`.
4. Update the relevant implementation phase.
5. Record any significant new architectural decision here.
6. Document unresolved issues and blockers.
7. Report exactly what was implemented and verified.

### Critical Rule

**The AI agent must not silently modify an accepted project decision.**

If a technical limitation makes an accepted decision impractical, explain the limitation, present the proposed alternative, and request approval before changing the architecture.

---

# 13. Final Decision Summary

The following architecture and product direction define the approved foundation of ANC:

- Native Swift macOS application.
- SwiftUI Settings interface.
- AppKit menu bar rendering.
- Network.framework for path detection.
- macOS interface byte counters for traffic measurement.
- Actual elapsed-time speed calculations.
- Decimal byte-based speed units.
- Three primary display modes.
- Shared dominant direction engine.
- Hysteresis for automatic switching.
- UserDefaults for preferences only.
- Swift Concurrency for asynchronous monitoring.
- Optional Launch at Login.
- No backend, database, cloud, or analytics.
- Universal Binary target.
- DMG-based installation.
- Developer ID signing and notarization preferred.

**Final Product Objective:**

Build a small, reliable, privacy-focused native macOS menu bar utility that displays accurate real-time download and upload speeds without unnecessary functionality or resource consumption.

---

**Document:** `PROJECT_DECISIONS.md`  
**Project:** ARRY Network Counter (ANC)  
**Organization:** ARRRY  
**Initial Decision Records:** 33  
**Status:** Active  
**Last Updated:** 2026-11-21