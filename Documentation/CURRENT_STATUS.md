# CURRENT_STATUS.md

# ARRY Network Counter (ANC)

**Organization:** ARRRY  
**Application:** ARRY Network Counter  
**Short Name:** ANC  
**Platform:** macOS  
**Technology:** Swift 6, SwiftUI, AppKit  
**Distribution:** DMG  
**Project Stage:** Documentation & Planning  
**Overall Status:** Ready for Development

---

## 1. Project Overview

ARRY Network Counter (ANC) is a lightweight native macOS menu bar utility designed to display real-time network download and upload speeds.

The application will provide three primary display modes:

1. Both Directions.
2. Single Direction — Manual.
3. Single Direction — Automatic.

Both Directions includes two display options:

- Separate Speeds.
- Combined Arrows with Switching Speed.

The application will use native macOS network interface statistics and display the calculated speeds directly in the menu bar.

The application will remain minimal, local-first, and independent of external services.

---

## 2. Current Project Status

<badge color="success">Documentation Complete</badge>

| Area | Status |
|---|---|
| Product Requirements | Completed |
| Technical Architecture | Completed |
| Implementation Roadmap | Completed |
| Current Status Tracking | Active |
| Xcode Project Initialization | Completed |
| Core Implementation | Completed |
| Network Monitoring | Completed |
| Menu Bar Integration | Completed (Phase 08) |
| Display Modes Implementation | Completed (Phase 09) |
| Settings Interface | Completed (Phase 10) |
| Application Lifecycle & Launch at Login | Completed (Phase 11) |
| Documentation & About Section | Completed (Phase 12) |
| Error Handling & Performance Optimization | Completed (Phase 13) |
| Testing | Completed (Phase 02–14 Unit Tests — 249 assertions passed) |
| DMG Packaging | Not Started |
| Production Release | Not Started |

**Current Development Phase:** Phase 14 Completed — Ready for Phase 15 (Universal Binary & DMG Packaging)  
**Next Action:** Begin Phase 15 implementation.

---

## 3. Documentation Status

The following documents define the project.

| Document | Purpose | Status |
|---|---|---|
| `PROJECT_REQUIREMENTS.md` | Product requirements and scope | Completed |
| `TECHNICAL_ARCHITECTURE.md` | Technical stack and system architecture | Completed |
| `IMPLEMENTATION_PHASES.md` | Sequential development roadmap | Completed |
| `CURRENT_STATUS.md` | Live implementation progress | Active |

### Documentation Rules

- `PROJECT_REQUIREMENTS.md` defines what the application must do.
- `TECHNICAL_ARCHITECTURE.md` defines how the application should be implemented.
- `IMPLEMENTATION_PHASES.md` defines the development sequence.
- `CURRENT_STATUS.md` records what has actually been implemented and verified.

All four documents must remain consistent.

---

## 4. Implementation Progress

### Overall Phase Tracking

| Phase | Name | Status |
|---|---|---|
| 01 | Project Initialization & Configuration | Completed |
| 02 | Core Models & Application Foundation | Completed |
| 03 | Network Path Detection | Completed |
| 04 | Network Interface Statistics | Completed |
| 05 | Network Speed Calculation Engine | Completed |
| 06 | Speed Formatting Engine | Completed |
| 07 | Dominant Direction & Switching Logic | Completed |
| 08 | Native Menu Bar Integration | Completed |
| 09 | Display Modes Implementation | Completed |
| 10 | Settings Interface & Preferences | Completed |
| 11 | Application Lifecycle & Launch at Login | Completed |
| 12 | Documentation & About Section | Completed |
| 13 | Error Handling & Performance Optimization | Completed |
| 14 | Comprehensive Testing & Compatibility | Completed |
| 15 | Universal Binary & DMG Packaging | Not Started |
| 16 | Final Release & Deployment Verification | Not Started |

### Progress Summary

| Metric | Current Value |
|---|---:|
| Total Phases | 16 |
| Completed Phases | 14 |
| In Progress Phases | 0 |
| Blocked Phases | 0 |
| Not Started Phases | 2 |
| Overall Implementation Progress | 87.5% |

Documentation completion is tracked separately and does not count as implementation progress.

---

## 5. Current Development Focus

### Phase 09 — Display Modes Implementation

**Priority:** Critical  
**Status:** Completed

#### Objective

Implement and integrate all supported menu bar display modes (Both Directions: Separate Speeds and Combined Arrows; Single Direction — Manual: Download and Upload; Single Direction — Automatic: Dominant Direction Switching) using the existing network monitoring, speed calculation, dominant-direction, formatting, and menu bar rendering architecture.

#### Completed Tasks

- [x] Configure 4-space horizontal spacer (`MenuBarAppearance.separateSpeedsSpacer = "    "`) for clean visual separation between download and upload in Separate Speeds mode.
- [x] Extend `MenuBarContent` with `singleDisplayedSpeedText` and `isIdle` convenience properties for unified single-speed introspection.
- [x] Implement `MenuBarContentBuilder` providing clean, centralized encapsulation of display mode business rules:
  - Both Directions (Separate Speeds): Independent download and upload speeds with dual arrows (`↓ <dl>    ↑ <ul>`).
  - Both Directions (Combined Arrows): Both arrows (`↓ ↑`) with single dominant speed, switching dynamically with hysteresis.
  - Single Direction Manual (Download): Strictly down arrow (`↓ <dl>`), ignoring upload and dominant-direction state.
  - Single Direction Manual (Upload): Strictly up arrow (`↑ <ul>`), ignoring download and dominant-direction state.
  - Single Direction Automatic: Single arrow (`↓ <dl>` or `↑ <ul>`) tracking active dominant direction dynamically.
  - Idle handling: Clean `0 KB/s` fallback per mode (`↓ 0 KB/s    ↑ 0 KB/s`, `↓ ↑ 0 KB/s`, `↓ 0 KB/s`, `↑ 0 KB/s`).
  - Disconnected handling: Graceful fallback when path state is unsatisfied.
- [x] Integrate `MenuBarContentBuilder` into `MenuBarManager.currentContentFromCoordinator()`.
- [x] Update `MenuBarRenderer` to render `MenuBarAppearance.separateSpeedsSpacer` between download and upload.
- [x] Ensure atomic coordinator state transitions: `dominantDirection` evaluated and published before `latestMeasurement`.
- [x] Verify monitoring persistence: Mode switching never restarts network monitoring, recreates `NSStatusItem`, or resets `speedCalculator`.
- [x] Implement 10 comprehensive unit tests in `Tests/MenuBarContentBuilderTests.swift`.
- [x] Implement 10 comprehensive integration tests in `Tests/DisplayModeIntegrationTests.swift`.
- [x] Update `Tests/TestRunner.swift` with Suite 17 and Suite 18 (160 assertions passing across 18 suites).

#### Deliverables Produced

- Display mode content builder: `ARRYNetworkCounter/MenuBar/MenuBarContentBuilder.swift`.
- Extended menu bar display model: `ARRYNetworkCounter/MenuBar/MenuBarContent.swift`.
- Updated appearance spacer: `ARRYNetworkCounter/MenuBar/MenuBarAppearance.swift`.
- Updated menu bar renderer: `ARRYNetworkCounter/MenuBar/MenuBarRenderer.swift`.
- Updated menu bar manager: `ARRYNetworkCounter/MenuBar/MenuBarManager.swift`.
- Unit test suite: `Tests/MenuBarContentBuilderTests.swift` (10 assertions).
- Integration test suite: `Tests/DisplayModeIntegrationTests.swift` (10 assertions).
- Updated test runner: `Tests/TestRunner.swift` (160 assertions passing across 18 test suites).

#### Completion Verification

- [x] Both Directions — Separate Speeds renders `↓ <dl>    ↑ <ul>` with independent dynamic updates.
- [x] Both Directions — Combined Arrows renders `↓ ↑ <dominantSpeed>` switching on dominance change.
- [x] Both Directions — Combined Arrows displays `↓ ↑ 0 KB/s` when idle.
- [x] Single Direction — Manual Download renders `↓ <dl>` and ignores upload rates.
- [x] Single Direction — Manual Upload renders `↑ <ul>` and ignores download rates.
- [x] Single Direction — Automatic renders single arrow (`↓` or `↑`) matching dominant direction.
- [x] Single Direction — Automatic displays `↓ 0 KB/s` when idle.
- [x] Mode transitions do not restart monitoring, recreate status item, or reset speed calculation.
- [x] 100% of unit tests pass (160 assertions across 18 test suites with 0 failures in 407 ms).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly for Debug and Release.

### Current Phase: Phase 14 — Comprehensive Testing & Compatibility

**Priority:** Critical  
**Status:** Completed

#### Objective

Perform a comprehensive testing and compatibility audit across unit, integration, scenario, platform compatibility, and resource benchmarks; validate all edge cases across speed calculation, decimal formatting, direction switching hysteresis, preferences resilience, and macOS 13.0 API surface characteristics; and deliver an exhaustive QA report.

#### Completed Tasks

- [x] Implemented dedicated boundary, edge-case, and stress test suite in `Tests/ComprehensiveCompatibilityTests.swift` (29 assertions) covering 8 distinct verification sections.
- [x] Validated network speed calculation edge cases: initial baseline establishment, zero throughput, micro-throughput (150 B/s), high-throughput (1.25 GB/s / 10 Gbps line rate), counter wrap/decrease protection, and sleep gap reset (> 10s).
- [x] Validated byte and speed formatting across all base-1000 SI scale boundaries (B/s, KB/s, MB/s, GB/s, TB/s), trailing zero suppression, POSIX decimal point consistency, and non-finite / negative value fallbacks to `0 KB/s`.
- [x] Validated dominant direction engine hysteresis under noise and jitter: relative 10% margin, absolute 10,000 B/s noise floor, 2-sample consecutive requirement, candidate cancellation on flapping, and idle download default.
- [x] Validated single-interface selection policy: active physical interfaces prioritised, loopback (`lo0`) strictly excluded, and inactive interfaces ignored.
- [x] Validated menu bar text formatting across all 4 display modes: Both Directions (Separate Speeds & Combined Arrows), Single Direction (Manual Download & Upload), and Single Direction (Automatic tracking dominance).
- [x] Validated preferences resilience: corrupted raw values in `UserDefaults` cleanly repaired with safe fallback to defaults, and live Combine updates verified.
- [x] Validated bundle resource integrity: `Info.plist` checked for `LSUIElement = true`, `LSMinimumSystemVersion = 13.0`, `CFBundleIdentifier = in.arrry.networkcounter`, and verified presence of all 4 offline documentation guides.
- [x] Executed concurrency and stress testing: 100 rapid preference updates and 50 high-frequency speed calculations executed without deadlocks or race conditions.
- [x] Conducted transient memory audit confirming zero historical network data is retained in memory or persisted to disk.
- [x] Verified Universal Binary compilation for both Debug and Release bundles containing `arm64` and `x86_64` Mach-O slices targeted to `macOS 13.0`.
- [x] Empirically profiled live Release process execution: steady-state CPU measured at 0.3%–0.4% (well within < 0.5% requirement) with stable ~86 MB RSS footprint.
- [x] Authored comprehensive formal QA report: `Documentation/TESTING_REPORT.md`.

#### Deliverables Produced

- Comprehensive test suite: `Tests/ComprehensiveCompatibilityTests.swift` (29 assertions).
- Updated test runner: `Tests/TestRunner.swift` (249 assertions passing across 25 test suites in ~808 ms).
- Formal testing report: `Documentation/TESTING_REPORT.md`.
- Verified Universal Binaries: `build/Debug/ARRY Network Counter.app` & `build/Release/ARRY Network Counter.app`.

#### Completion Verification

- [x] All 25 unit test suites pass (249 assertions with 0 failures).
- [x] All 4 display modes work correctly and render exact plain text patterns.
- [x] Universal Binary slices (`arm64` + `x86_64`) verified for Debug and Release via `lipo -info`.
- [x] Load commands verify `minos 13.0` across both architecture slices.
- [x] Steady-state CPU usage is 0.3%–0.4% (< 0.5% target).
- [x] Zero memory leaks, zero persistence of network history.
- [x] No release-blocking defects remain.

**Next Step:** Proceed to Phase 15 — Universal Binary & DMG Packaging.

---

### Previous Phase: Phase 13 — Error Handling & Performance Optimization

**Priority:** High  
**Status:** Completed

#### Objective

Conduct a comprehensive stability, reliability, resource-usage, and performance audit of the monitoring pipeline, implement interface retrieval failure recovery, enforce sleep/suspension timing bounds and counter-reset protection, eliminate redundant AppKit menu-bar renders, and verify transient memory and strict privacy constraints.

#### Completed Tasks

- [x] Implemented centralized Unified Logging via `AppLogger` (`os.Logger`) across Lifecycle, Network, Settings, and MenuBar categories without logging sensitive payloads or spamming.
- [x] Hardened `NetworkPathManager.sampleCurrentSnapshot()` with `do-catch` recovery: interface statistics enumeration errors clear `currentSnapshot = nil`, transition `currentSelectionResult = .enumerationFailed(message:)`, and log diagnostic notices without crashing or propagating stale snapshots.
- [x] Extended `NetworkInterfaceSelector.SelectionResult` with `.enumerationFailed(message:)` to distinguish hardware/OS enumeration failures from valid zero-interface states.
- [x] Enhanced network disconnection/reconnection recovery: path state transitioning to `.unsatisfied` immediately clears `currentSnapshot = nil` in `NetworkPathManager` and resets `speedCalculator` and `directionEngine` in `ApplicationCoordinator`. Reconnection establishes a fresh baseline without calculating across the disconnected gap.
- [x] Hardened `NetworkSpeedCalculator` with configurable `maximumMeasurementIntervalSeconds` (default: 10.0 s): elapsed intervals exceeding the limit (e.g. system sleep/wake or long scheduling pauses) reset the baseline (`.baselineReset(reason: .intervalTooLong)`) to prevent artificial multi-second spikes.
- [x] Implemented counter decrease protection: decreased cumulative bytes (kernel resets or rollover) immediately trigger `.baselineReset(reason: .counterDecreased)`, establishing a new baseline without integer underflow or invalid speed spikes.
- [x] Protected `DominantDirectionEngine` entry point against non-finite values (NaN / Infinity), safely falling back to `.defaultDirection` (`.download`) without triggering false direction switches.
- [x] Coalesced `ApplicationCoordinator` baseline resets: when `speedCalculator.calculateSpeed` produces no measurement or resets, `coordinator.latestMeasurement` is cleared to `nil` and `directionEngine` is reset to prevent stale speed display.
- [x] Optimized `MenuBarManager` rendering: added `.removeDuplicates()` on Combine subscriptions, tracked `renderCount`, and enforced strict change detection against `lastRenderedContent`. Identical speeds/content skip AppKit `button.attributedTitle` updates completely, cutting CPU consumption to 1.7% and eliminating WindowServer redraw spam.
- [x] Conducted comprehensive privacy and memory audit: verified zero persistent traffic history in `UserDefaults` and zero outbound/inbound network requests in monitoring code.
- [x] Created `Tests/ErrorHandlingAndPerformanceTests.swift` (12 assertions) and integrated suite 24 into `Tests/TestRunner.swift` (220 assertions passing across 24 test suites in ~804 ms).
- [x] Verified Universal Binary builds for Debug and Release containing `arm64` and `x86_64` slices.

#### Deliverables Produced

- Centralized logger: `ARRYNetworkCounter/Core/Utilities/AppLogger.swift`.
- Hardened path manager: `ARRYNetworkCounter/Services/Network/NetworkPathManager.swift`.
- Extended selector result: `ARRYNetworkCounter/Services/Network/NetworkInterfaceSelector.swift`.
- Hardened speed calculator: `ARRYNetworkCounter/Services/Monitoring/NetworkSpeedCalculator.swift`.
- Hardened dominant direction engine: `ARRYNetworkCounter/Services/Monitoring/DominantDirectionEngine.swift`.
- Hardened coordinator: `ARRYNetworkCounter/App/ApplicationCoordinator.swift`.
- Optimized menu bar manager: `ARRYNetworkCounter/MenuBar/MenuBarManager.swift`.
- Unit test suite: `Tests/ErrorHandlingAndPerformanceTests.swift` (12 assertions).
- Updated test runner: `Tests/TestRunner.swift` (220 assertions passing across 24 test suites).

#### Completion Verification

- [x] Temporary statistics retrieval failures do not crash the app and clear stale snapshots.
- [x] Monitoring recovers cleanly after network disconnection and reconnection.
- [x] Counter decreases reset baseline without calculation spikes or unsigned underflow.
- [x] Excessive sampling intervals (> 10s sleep/wake) reset baseline to prevent artificial spikes.
- [x] Identical content skips AppKit menu bar redrawing (verified via `renderCount`).
- [x] Process CPU usage measured at 1.7% during active monitoring with 87 MB RSS.
- [x] Zero network traffic history or metrics are persisted to disk.
- [x] 100% of unit tests pass (220 assertions across 24 test suites with 0 failures).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly for Debug and Release.

**Next Step:** Proceed to Phase 14 — Comprehensive Testing & Compatibility.

---

### Previous Phase: Phase 12 — Documentation & About Section

**Priority:** Medium  
**Status:** Completed

#### Objective

Create complete, accurate, offline-accessible user documentation, bundle it within the application bundle, and integrate a polished native About section and markdown reader into the Settings interface.

#### Completed Tasks

- [x] Authored `SETUP_GUIDE.md` covering macOS 13.0+ requirements, Universal Binary support (arm64 & Intel), DMG installation steps, Gatekeeper security approval for ad-hoc preview builds, menu-bar utility behavior (`LSUIElement`), and `SMAppService` login launch configuration.
- [x] Authored `USAGE_GUIDE.md` detailing real-time kernel counter monitoring (`getifaddrs`), all 4 display modes, 3-factor hysteresis direction switching rules (10% relative margin, 10,000 B/s threshold, 2 consecutive samples, idle download default), SI decimal units, Byte vs. bit distinction (8 bits = 1 Byte), and kernel measurement characteristics.
- [x] Authored `TERMS_AND_CONDITIONS.md` providing standard license terms, permitted use, measurement accuracy disclaimers, no-warranty provisions ("as is"), Apple Inc. trademark disclaimers, ARRRY brand ownership, and limitation of liability.
- [x] Authored `PRIVACY_POLICY.md` backed by comprehensive source-code audit confirming zero remote network activity, zero analytics/telemetry, in-memory volatile throughput calculation, and local storage strictly limited to 4 user preferences in `UserDefaults`.
- [x] Implemented `DocumentationDocument` enum and `DocumentationLoader` provider with bundle resource and filesystem fallback search paths.
- [x] Implemented `DocumentReaderView` rendering native scrollable markdown content with custom block parsing (H1-H4, dividers, code blocks, tables, blockquotes, paragraphs) and back navigation.
- [x] Implemented `AboutView` featuring the official `AppLogo` asset, dynamic bundle versioning (`CFBundleShortVersionString`, `CFBundleVersion`, `NSHumanReadableCopyright`), ARRRY brand attribution, and quick links to legal documents.
- [x] Restructured `SettingsView` with native segmented tab navigation (`Preferences`, `Documentation`, `About`) driven by `SettingsManager`.
- [x] Updated `Scripts/build.sh` to package documentation markdown files into `$RESOURCES_DIR/Documentation/` for both Debug and Release bundles.
- [x] Implemented comprehensive unit tests in `Tests/DocumentationTests.swift` (10 assertions).
- [x] Updated `Tests/TestRunner.swift` with suite 23 (208 assertions passing across 23 test suites in ~699 ms).
- [x] Verified Universal Binary builds for Debug and Release containing `arm64` and `x86_64` slices.

#### Deliverables Produced

- User guides: `Documentation/UserGuides/SETUP_GUIDE.md`, `Documentation/UserGuides/USAGE_GUIDE.md`.
- Legal documents: `Documentation/Legal/TERMS_AND_CONDITIONS.md`, `Documentation/Legal/PRIVACY_POLICY.md`.
- Bundled documentation resources: `ARRYNetworkCounter/Resources/Documentation/`.
- Documentation provider & loader: `ARRYNetworkCounter/Services/Documentation/DocumentationProvider.swift`.
- Native markdown reader: `ARRYNetworkCounter/Settings/DocumentReaderView.swift`.
- About view: `ARRYNetworkCounter/Settings/AboutView.swift`.
- Updated settings manager & view: `ARRYNetworkCounter/Settings/SettingsManager.swift`, `ARRYNetworkCounter/Settings/SettingsView.swift`.
- Dynamic bundle metadata provider: `ARRYNetworkCounter/Core/Utilities/AppConfiguration.swift`.
- Unit test suite: `Tests/DocumentationTests.swift` (10 assertions).
- Updated test runner: `Tests/TestRunner.swift` (208 assertions passing across 23 test suites).

#### Completion Verification

- [x] All 4 documentation markdown files exist, contain required sections, and are free of placeholders.
- [x] Documentation is accessible offline and bundled in `Contents/Resources/Documentation/` in both Debug and Release `.app` bundles.
- [x] Privacy statements strictly verified against source-code evidence (zero network requests, no telemetry, in-memory counters, 4 local preference keys).
- [x] About section displays official logo, app name, short name, organization, version, build number, and copyright read dynamically from bundle metadata.
- [x] Native document reader provides readable scrolling, headings, dividers, code blocks, tables, and back navigation to Settings.
- [x] 100% of unit tests pass (208 assertions across 23 test suites with 0 failures).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly without warnings for Debug and Release.

**Next Step:** Proceed to Phase 13 — Error Handling & Performance Optimization.

---

### Previous Phase: Phase 11 — Application Lifecycle & Launch at Login

**Priority:** High  
**Status:** Completed

#### Objective

Establish reliable application startup and shutdown behavior, enforce that only one network monitoring pipeline and sampling task exist per application instance, handle application termination cleanly with controlled asynchronous AppKit shutdown, and implement optional macOS login launch registration using Apple's supported `ServiceManagement` and `SMAppService.mainApp` APIs with full Settings synchronization and mockable test abstractions.

#### Completed Tasks

- [x] Implemented `ApplicationLifecycleState` model (`notStarted`, `starting`, `running`, `stopping`, `stopped`, `failed`) and state transitions in `ApplicationCoordinator`.
- [x] Enforced single monitoring pipeline guarantee: only 1 active `NWPathMonitor`, 1 active sampling task, 1 active snapshot pipeline, and idempotent `start()` and `stop()` calls.
- [x] Implemented periodic sampling task in `NetworkPathManager` with explicit lifecycle ownership, safe cancellation, and session ID token invalidation to reject stale callbacks.
- [x] Implemented AppKit controlled asynchronous shutdown in `AppDelegate.applicationShouldTerminate(_:)` using `.terminateLater` and `NSApp.reply(toApplicationShouldTerminate: true)` so macOS waits for coordinator shutdown.
- [x] Implemented `LoginItemProviding` protocol, `SystemLoginItemProvider` backed by `SMAppService.mainApp`, and `MockLoginItemProvider` for isolated unit testing without touching user system settings.
- [x] Implemented `LoginItemManager` managing actual macOS login item registration, unregistration, status queries (`enabled`, `notRegistered`, `requiresApproval`, `notFound`), and opening System Settings > Login Items via supported APIs.
- [x] Synchronized `SettingsManager` and `SettingsView` with `LoginItemManager` real system status, showing dynamic feedback, approval warnings, and actionable error messages.
- [x] Implemented comprehensive unit tests: `Tests/ApplicationLifecycleTests.swift` (10 assertions) and `Tests/LoginItemManagerTests.swift` (10 assertions).
- [x] Updated `Tests/TestRunner.swift` to execute all 22 test suites (198 passing assertions with 0 failures in 704 ms).
- [x] Verified Universal Binary builds for Debug and Release containing `arm64` and `x86_64` slices.

#### Deliverables Produced

- Login item manager & providers: `ARRYNetworkCounter/Services/Lifecycle/LoginItemManager.swift`.
- Updated application coordinator: `ARRYNetworkCounter/App/ApplicationCoordinator.swift`.
- Updated path manager with sampling task: `ARRYNetworkCounter/Services/Network/NetworkPathManager.swift`.
- Updated application delegate with controlled termination: `ARRYNetworkCounter/App/AppDelegate.swift`.
- Updated settings manager & view: `ARRYNetworkCounter/Settings/SettingsManager.swift`, `ARRYNetworkCounter/Settings/SettingsView.swift`.
- Lifecycle unit tests: `Tests/ApplicationLifecycleTests.swift` (10 assertions).
- Login item unit tests: `Tests/LoginItemManagerTests.swift` (10 assertions).
- Updated test runner: `Tests/TestRunner.swift` (198 assertions passing across 22 test suites).

#### Completion Verification

- [x] Application startup coordinates services, loads preferences, starts menu bar, and activates monitoring.
- [x] Monitoring starts automatically on launch.
- [x] Single monitoring pipeline invariant enforced: repeated `start()` or `startMonitoring()` calls do not create duplicate monitors, tasks, or streams.
- [x] Monitoring cancellation is safe, structured, and idempotent.
- [x] Restarting monitoring re-establishes a fresh baseline without residual calculation state.
- [x] Controlled asynchronous termination completes cleanly before macOS commits app termination.
- [x] `SMAppService.mainApp` registration and unregistration work correctly via `LoginItemManager`.
- [x] Settings Launch at Login toggle accurately reflects authoritative macOS registration status.
- [x] Statuses `.requiresApproval` and `.notFound` and registration errors are handled safely without crashing.
- [x] Application operates normally when login launch is disabled or unavailable.
- [x] 100% of unit tests pass (198 assertions across 22 test suites with 0 failures).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly for Debug and Release.

**Next Step:** Proceed to Phase 12 — Documentation & About Section.

---

### Previous Phase: Phase 10 — Settings Interface & Preferences

**Priority:** High  
**Status:** Completed

#### Objective

Implement a compact, clean native macOS Settings interface with persistent user preferences (`PreferencesStore`), presentation coordination (`SettingsManager`), native SwiftUI settings view (`SettingsView`), immediate menu-bar display update propagation without monitoring restarts, launch-at-login preference management and Phase 11 boundary definition, and documentation navigation to repository documentation resources.

#### Completed Tasks

- [x] Implemented `PreferencesStore` with typed reads/writes, safe defaults, corrupted value auto-repair, independent key updates, and support for isolated `UserDefaults` suites.
- [x] Implemented `LaunchAtLoginManaging` protocol and `LaunchAtLoginService` providing the Phase 10 preference model and Phase 11 boundary definition.
- [x] Implemented `SettingsManager` as the `@MainActor` presentation manager for the Settings window, preventing duplicate windows and propagating setting changes immediately.
- [x] Implemented `SettingsView` in SwiftUI using a native macOS utility aesthetic, presenting conditional display controls (Both Directions, Single Direction — Manual, Single Direction — Automatic), speed previews with monospaced digits and colored arrows, launch-at-login toggle with Phase 11 footnote, and navigation to local project documentation.
- [x] Extended `ApplicationCoordinator` with synchronous and asynchronous preference propagation (`applyPreferences`).
- [x] Connected menu bar context menu `Settings...` action to `SettingsManager.showSettingsWindow()`.
- [x] Implemented unit and integration tests in `PreferencesStoreTests` (8 assertions) and `SettingsBehaviorTests` (10 assertions).
- [x] Verified Universal Binary builds for Debug and Release containing `arm64` and `x86_64` slices.

#### Deliverables Produced

- Preferences store: `ARRYNetworkCounter/Services/Preferences/PreferencesStore.swift`.
- Launch at login service boundary: `ARRYNetworkCounter/Services/Preferences/LaunchAtLoginService.swift`.
- Settings presentation manager: `ARRYNetworkCounter/Settings/SettingsManager.swift`.
- Native SwiftUI settings view: `ARRYNetworkCounter/Settings/SettingsView.swift`.
- Preferences unit test suite: `Tests/PreferencesStoreTests.swift` (8 assertions).
- Settings behavior integration test suite: `Tests/SettingsBehaviorTests.swift` (10 assertions).
- Updated test runner: `Tests/TestRunner.swift` (178 assertions passing across 20 test suites).

#### Completion Verification

- [x] Settings window opens from menu bar context menu and focuses existing window if already open.
- [x] All three display modes (Both Directions, Manual, Automatic) configure cleanly.
- [x] Both Directions styles (Separate Speeds, Combined Arrows) update and persist.
- [x] Manual Direction (Download, Upload) updates, persists, and is never overridden by dominance engine.
- [x] Inactive mode preferences are preserved across mode switches.
- [x] Preference changes reflect immediately in the menu bar without restarting monitoring or recreating `NSStatusItem`.
- [x] Preferences persist across store instances and application relaunches.
- [x] Corrupted or invalid stored values are detected, repaired, and safely fall back to defaults without crashing.
- [x] Launch at login preference is persisted and accurately reflected without falsely claiming OS registration.
- [x] Navigation buttons open actual existing documentation files (`README.md`, `TECHNICAL_ARCHITECTURE.md`, `PROJECT_REQUIREMENTS.md`, `PROJECT_DECISIONS.md`).
- [x] 100% of unit and integration tests pass (178 assertions across 20 test suites with 0 failures in 609 ms).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly for Debug and Release.

**Next Step:** Proceed to Phase 11 — Application Lifecycle & Launch at Login.

---

### Previous Phase: Phase 09 — Display Modes Implementation

**Priority:** Critical  
**Status:** Completed

#### Objective

Implement a native macOS menu bar status item (`NSStatusItem`) using AppKit, providing real-time, easily understandable network speed indication directly in the menu bar, integrated with `ApplicationCoordinator`, `SpeedFormatter`, and `DominantDirectionEngine`, styled with green download arrows (`↓`), blue upload arrows (`↑`), monospaced digits, light/dark appearance compatibility, context menu (Settings, Quit), and official ARRRY Network Counter branding.

#### Completed Tasks

- [x] Implement `MenuBarAppearance` with semantic colors (green `#30B86B`, blue `#3988E8`, dynamic `headerTextColor`), symbols (`↓`, `↑`), and monospaced digit typography.
- [x] Implement `MenuBarContent` immutable display model representing active speeds, dominant direction, display mode, and connection status.
- [x] Implement `MenuBarRenderer` converting display content into styled `NSAttributedString` instances and plain text representations.
- [x] Implement `MenuBarMenuBuilder` creating native macOS `NSMenu` with `Settings...` (`Cmd+,`), separator, and `Quit ARRY Network Counter` (`Cmd+Q`).
- [x] Implement `MenuBarManager` (`@MainActor`) managing `NSStatusItem.variableLength` lifecycle, Combine-driven coordinator observation, diff-based redraw suppression, button attributed title updates, accessibility labels, and clean removal on stop.
- [x] Integrate `MenuBarManager` into `AppDelegate` lifecycle (`applicationDidFinishLaunching` and `applicationWillTerminate`).
- [x] Integrate official ARRRY Network Counter application logo (`media_1795277151727_cc894535.jpg`) into `AppIcon.appiconset` (10 standard macOS resolutions), compiled `AppIcon.icns` via `iconutil`, and `AppLogo.imageset` for in-app UI branding.
- [x] Configure `Info.plist` with `CFBundleIconFile` and `CFBundleIconName` pointing to `AppIcon`.
- [x] Update `Scripts/build.sh` to copy `AppIcon.icns` into application bundle resources.
- [x] Formulate and document menu bar attribution and typographic standards in `ADR-036`.
- [x] Implement 10 comprehensive unit tests in `Tests/MenuBarRendererTests.swift`.
- [x] Implement 6 comprehensive unit tests in `Tests/MenuBarManagerTests.swift`.
- [x] Expand test harness in `Tests/TestRunner.swift` (140 assertions passing across 16 test suites).

#### Deliverables Produced

- Menu bar appearance: `ARRYNetworkCounter/MenuBar/MenuBarAppearance.swift`.
- Menu bar display model: `ARRYNetworkCounter/MenuBar/MenuBarContent.swift`.
- Menu bar renderer: `ARRYNetworkCounter/MenuBar/MenuBarRenderer.swift`.
- Menu bar menu builder: `ARRYNetworkCounter/MenuBar/MenuBarMenuBuilder.swift`.
- Menu bar manager: `ARRYNetworkCounter/MenuBar/MenuBarManager.swift`.
- Application delegate integration: `ARRYNetworkCounter/App/AppDelegate.swift`.
- Official app icon: `AppIcon.icns` (1024x1024 with all resolutions) and `Assets.xcassets/AppIcon.appiconset/`.
- Official branding logo: `Assets.xcassets/AppLogo.imageset/AppLogo.png`.
- Architecture Decision Record: `ADR-036 — Native Menu Bar Status Item Attribution and Typographic Standards`.
- Unit test suites: `Tests/MenuBarRendererTests.swift` (10 assertions) and `Tests/MenuBarManagerTests.swift` (6 assertions).
- Updated test runner: `Tests/TestRunner.swift` (140 assertions passing across 16 test suites).

#### Completion Verification

- [x] Status item appears on application launch using `NSStatusItem.variableLength`.
- [x] Download arrow renders in vibrant green (`#30B86B`).
- [x] Upload arrow renders in vibrant blue (`#3988E8`).
- [x] Speed values use existing `SpeedFormatter` with monospaced digit typography.
- [x] Text adapts cleanly to macOS Light Mode, Dark Mode, and menu bar translucency.
- [x] Status item updates dynamically from coordinator without opening any window.
- [x] Native context menu functions: Settings action and Quit action.
- [x] Status item is removed cleanly from `NSStatusBar.system` on termination.
- [x] No Dock icon appears during normal operation (`LSUIElement = true`).
- [x] Official ARRRY Network Counter icon integrated across all resolutions and verified in bundle.
- [x] 100% of unit tests pass (140 assertions across 16 test suites with 0 failures in 195.66 ms).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly for Debug and Release.

**Next Step:** Proceed to Phase 09 — Display Modes Implementation.

---

## 6. Implemented Features

This section must contain only features that have actually been implemented and verified.

### Currently Implemented

- Native macOS application project structure initialized (`ARRYNetworkCounter.xcodeproj`).
- Application entry point with SwiftUI `@main` (`ARRYNetworkCounterApp.swift`).
- AppKit application delegate lifecycle integration (`AppDelegate.swift`) integrating `ApplicationCoordinator`.
- Application metadata and bundle configuration (`Info.plist`) with `LSUIElement = true`.
- Native macOS asset catalog initialized (`Assets.xcassets` and `AppIcon.appiconset`).
- Universal Binary dual-architecture compilation and packaging (`arm64` and `x86_64`).
- Automated dual-configuration build script (`Scripts/build.sh`).
- Core domain value models: `NetworkSpeed`, `NetworkSnapshot`, `NetworkInterface`.
- Strongly typed display configuration models: `DisplayMode`, `BothDirectionsStyle`, `NetworkDirection`.
- Persisted settings model: `AppPreferences` with default values and JSON Codable support.
- Protocol contracts: `NetworkMonitoring`, `PreferencesStoring` (with in-memory and UserDefaults implementations).
- Central application coordinator: `ApplicationCoordinator` (`@MainActor`).
- Centralized configuration constants: `AppConfiguration`.
- Native macOS network path awareness: `NetworkPathState` (connectivity status, interface categorization, expensive/constrained flags).
- Native macOS network path manager: `NetworkPathManager` (actor managing `NWPathMonitor` lifecycle, serial queue callbacks, duplicate state suppression, session-based stale callback rejection, and interface statistics coordination).
- Protocol-driven path monitoring provider: `PathMonitorProviding` with `SystemPathMonitorProvider` and `MockPathMonitorProvider`.
- Live path update streaming and `@Published pathState` observation in `ApplicationCoordinator`.
- Native BSD interface statistics model: `NetworkInterfaceStatistics` (`ifi_ibytes`, `ifi_obytes`, monotonic nanosecond timestamps, operational flags, loopback/virtual identification).
- Protocol-driven interface statistics provider: `NetworkInterfaceProviding` with `SystemNetworkInterfaceProvider` (`getifaddrs()`, `AF_LINK`, `struct if_data`, unconditional `freeifaddrs()`) and thread-safe actor-isolated `MockNetworkInterfaceProvider`.
- Intelligent interface selector: `NetworkInterfaceSelector` with single-interface selection policy, explicit `SelectionResult` and `SelectionReason`, priority ranking (Ethernet > Wi-Fi > Cellular > Other), loopback exclusion, and virtual tunnel zero-double-counting protection.
- Live snapshot emission pipeline in `NetworkPathManager` (`sampleCurrentSnapshot()` and `snapshotStream`).
- Live snapshot observation in `ApplicationCoordinator` (`@Published currentSnapshot`).
- Network speed calculation engine: `NetworkSpeedCalculator` (Swift actor managing baseline lifecycle, monotonic nanosecond elapsed-time calculations, independent download/upload calculation, and zero underflow protection).
- Typed speed measurement models: `SpeedMeasurement` (download, upload, elapsedSeconds, monotonicTimeNanoseconds, interface) and `SpeedCalculationResult` (`.calculated`, `.baselineEstablished`, `.baselineReset`, `.sampleRejected`, `.noActivePath`).
- Integrated speed calculation in `ApplicationCoordinator` (`@Published speedResult` and `@Published latestMeasurement`).
- Reusable speed formatting engine: `ByteFormatter` and `SpeedFormatter` (stateless value types converting raw speeds to decimal SI units `B/s`, `KB/s`, `MB/s`, `GB/s`, `TB/s`).
- Structured formatted speed representation: `FormattedByteSpeed` detailing numeric value, selected `SpeedUnit`, formatted string, and display string.
- Decimal precision policy: integer display for `B/s`, up to 2 decimal places with trailing zero and trailing decimal separator trimming for `KB/s`, `MB/s`, `GB/s`, `TB/s`.
- Explicit zero display requirement: zero throughput displays strictly as `0 KB/s`.
- Unit boundary rounding policy (`ADR-034`): unit selection evaluated on raw speed prior to rounding.
- Dominant direction decision engine: `DominantDirectionEngine` (Swift actor evaluating download and upload rates against hysteresis rules, maintaining candidate streaks, and publishing decisions).
- Direction decision and switching configuration models: `DirectionDecision` and `DirectionSwitchingConfiguration`.
- Direction switching hysteresis and noise suppression (`ADR-007`, `ADR-035`): 10% relative switching margin, 10 KB/s absolute noise floor threshold, 2 consecutive sample confirmation, and immediate candidate reset on qualification failure.
- Direction idle reversion: immediate transition to `.download` default when both traffic rates are idle ($\le 0$ B/s).
- IEEE 754 micro-epsilon handling ($1\times 10^{-7}$ tolerance) preventing floating-point boundary representation errors.
- Central coordinator dominant direction integration: `@Published public private(set) var dominantDirection: NetworkDirection` in `ApplicationCoordinator`.
- Native menu bar appearance styling: `MenuBarAppearance` (green `#30B86B` for `↓`, blue `#3988E8` for `↑`, dynamic `headerTextColor`, monospaced digit typography `NSFont.monospacedDigitSystemFont`, 4-space horizontal spacer).
- Menu bar display model: `MenuBarContent` (immutable `Sendable` representation of display modes, styles, speeds, direction, `singleDisplayedSpeedText`, and `isIdle`).
- Menu bar content builder: `MenuBarContentBuilder` (stateless encapsulation of display mode rules, formatting delegation, dominant direction resolution, and idle/disconnected fallbacks).
- Menu bar renderer: `MenuBarRenderer` (stateless conversion of `MenuBarContent` to `NSAttributedString` with custom spacers and unadorned accessibility plain text).
- Menu bar menu builder: `MenuBarMenuBuilder` (native context menu with `Settings...`, separator, and `Quit ARRY Network Counter`).
- Menu bar manager: `MenuBarManager` (`@MainActor` managing `NSStatusItem.variableLength` lifecycle, Combine observation, diff-based redraw suppression, button updates, and cleanup).
- Display Mode 1: Both Directions — Separate Speeds (`↓ <dl>    ↑ <ul>`, idle `↓ 0 KB/s    ↑ 0 KB/s`).
- Display Mode 1: Both Directions — Combined Arrows (`↓ ↑ <dominant>`, idle `↓ ↑ 0 KB/s`).
- Display Mode 2: Single Direction — Manual Download (`↓ <dl>`, idle `↓ 0 KB/s`, ignores upload).
- Display Mode 2: Single Direction — Manual Upload (`↑ <ul>`, idle `↑ 0 KB/s`, ignores download).
- Display Mode 3: Single Direction — Automatic (`↓ <dl>` or `↑ <ul>` following dominant direction, idle `↓ 0 KB/s`).
- Application delegate integration: `AppDelegate` (owning `MenuBarManager` and coordinating start/stop lifecycles).
- Official ARRRY Network Counter application logo: `AppIcon.icns` (1024x1024 with all 10 standard resolutions), `Assets.xcassets/AppIcon.appiconset/`, and `Assets.xcassets/AppLogo.imageset/`.
- Automated test suite and test runner: `Tests/`, `Scripts/test.sh` (160 assertion checks across 18 test suites).

### Verified Functionality

- Debug and Release application bundles build cleanly without warnings or errors.
- Universal Binary executable verified with `lipo -info` containing both `arm64` and `x86_64` architecture slices.
- Menu bar utility configuration (`LSUIElement = true`) verified via `plutil`.
- Application launch verified on macOS without crashing for both Debug and Release bundles.
- Full Phase 02 through Phase 09 unit and integration test suites pass: 160 assertions verified across 18 test suites with 0 failures in 407 ms.
- Empirical verification of `SystemNetworkInterfaceProvider` against live macOS `netstat -ib`: 100% byte-for-byte counter match on active Wi-Fi interface (`en0`).
- Safe C memory deallocation verified with `freeifaddrs()` invoked on every code path via Swift `defer`.
- Speed calculation verified across normal, fractional, irregular, small intervals, large counters, zero traffic, counter decreases, interface transitions, and disconnection lifecycles.
- Formatting verified across all units, boundary values, decimal precision, trailing-zero stripping, zero display (`0 KB/s`), and POSIX locale independence.
- Dominant direction switching verified across clear download/upload dominance, relative margin thresholds, absolute noise floors, consecutive sample confirmation, streak interruption, idle reversion, near-equal oscillation stability, and coordinator lifecycle resets.
- Menu bar rendering verified across all display modes, combined arrows, separate speeds, manual direction selection, automatic direction selection, idle fallback, and disconnected fallback.
- Menu bar status item lifecycle verified: singleton creation, idempotent starts, menu configuration, button updates, and clean removal on stop.
- Display mode switching verified: transitions between all modes and sub-styles update the status item dynamically without restarting network monitoring, recreating the `NSStatusItem`, or resetting the speed calculation engine.

### Important Rule

Do not move planned features into this section merely because their requirements or architecture have been documented.

A feature can be marked implemented only after its code exists and its relevant acceptance criteria have been verified.

---

## 7. Technical Configuration

### Approved Technology Stack

| Component | Selected Technology |
|---|---|
| Language | Swift 6 |
| Interface | SwiftUI |
| Menu Bar | AppKit |
| Network Path | Network.framework |
| Network Counters | getifaddrs / System Interface Counters |
| Concurrency | Swift Concurrency |
| Preferences | UserDefaults |
| Login Launch | ServiceManagement |
| IDE | Xcode |
| Installer | DMG |

### Target Platform

- Operating System: macOS.
- Architecture: Universal Binary.
- Apple Silicon: `arm64`.
- Intel: `x86_64`.

### Configuration Status

| Configuration | Status |
|---|---|
| Bundle Identifier | `in.arrry.networkcounter` (Configured) |
| Minimum macOS Version | macOS 13.0 (Configured) |
| Xcode Project Settings | Configured (`ARRYNetworkCounter.xcodeproj`) |
| Application Version | 1.0.0 (Build 1) (Configured) |
| Developer ID Certificate | Pending (Planned for Phase 15/16) |
| Notarization Credentials | Pending (Planned for Phase 15/16) |

---

## 8. Important Architecture Decisions

The following decisions are currently approved.

| Area | Decision |
|---|---|
| Application Type | Native macOS Menu Bar Utility |
| Main Interface | macOS Menu Bar |
| Settings Interface | Compact SwiftUI Window |
| Menu Bar Integration | AppKit NSStatusItem |
| Network Path Detection | NWPathMonitor |
| Traffic Measurement | macOS Interface Byte Counters |
| Speed Calculation | Byte Counter Delta / Actual Elapsed Time |
| Units | Decimal KB/s, MB/s, GB/s, TB/s |
| Direction Switching | Shared Dominant Direction Engine |
| Switching Stability | Hysteresis and Sample Confirmation |
| Preferences | UserDefaults |
| Persistent Traffic History | Not Allowed |
| Backend | Not Required |
| Database | Not Required |
| Analytics | Not Allowed |
| Distribution | DMG |
| Binary Target | Universal Binary |

Changes to these decisions must be reflected in `PROJECT_DECISIONS.md` if one is introduced later, as well as the relevant architecture and requirements documents.

---

## 9. Known Technical Considerations

The following items require particular attention during implementation and testing.

### Network Interface Selection

macOS exposes multiple physical and virtual interfaces.

The implementation must avoid blindly summing every interface because overlapping counters can result in double-counted traffic.

The selected interface must be validated against the active network path.

### VPN Handling

VPN interfaces can expose traffic separately from their underlying physical interfaces.

The application must establish and document a consistent measurement strategy without accidentally counting the same traffic twice.

### Counter Resets

Network interface counters can reset when interfaces are recreated or connections change.

A new baseline must be established instead of calculating a negative or artificially high speed.

### Sampling Accuracy

Speed calculations must use actual elapsed time rather than assuming every sampling operation occurs at an exact one-second interval.

### Menu Bar Space

Combined and separate display modes have different width requirements.

The status item must remain readable without consuming unnecessary menu bar space.

### macOS Distribution

Universal Binary compatibility, code signing, notarization, and DMG installation must be verified before release.

---

## 10. Bugs & Issues

No known implementation bugs currently exist because development has not started.

| ID | Issue | Severity | Status |
|---|---|---|---|
| — | No known implementation issues | — | — |

New issues must be recorded with:

- Issue ID.
- Description.
- Severity.
- Reproduction steps.
- Current status.
- Resolution.

---

## 11. Blockers & Dependencies

### Current Blockers

None identified.

### External Dependencies

| Dependency | Requirement | Status |
|---|---|---|
| Xcode | macOS development environment | Pending setup |
| macOS Development Mac | Build and runtime testing | Available for development |
| Apple Developer Program | Developer ID distribution and notarization | Pending decision |
| Intel Mac | Native Intel hardware testing | Availability to be verified |

Lack of an Intel Mac does not prevent building the `x86_64` Universal Binary slice, but native Intel hardware testing should be performed before claiming verified Intel compatibility.

---

## 12. Development Change Log

Record meaningful implementation milestones here.

| Date | Phase | Change | Status |
|---|---|---|---|
| 2026-11-21 | Documentation | Created PROJECT_REQUIREMENTS.md | Completed |
| 2026-11-21 | Documentation | Created TECHNICAL_ARCHITECTURE.md | Completed |
| 2026-11-21 | Documentation | Created IMPLEMENTATION_PHASES.md | Completed |
| 2026-11-21 | Documentation | Created CURRENT_STATUS.md | Completed |
| 2026-11-21 | Phase 01 | Initialized native Xcode project, directory structure, Swift 6 entry point, and verified Universal Binary build | Completed |
| 2026-11-21 | Phase 02 | Implemented core models, protocol abstractions, application coordinator, configuration constants, and verified unit test suite | Completed |
| 2026-11-21 | Phase 03 | Integrated Network.framework, implemented NetworkPathManager and NetworkPathState, connected path observation to ApplicationCoordinator, and verified tests | Completed |
| 2026-11-21 | Phase 04 | Implemented BSD interface statistics (getifaddrs/if_data), NetworkInterfaceSelector with single-interface policy, snapshot pipeline, live netstat -ib empirical validation, and 11 unit test suites (63 assertions passing) | Completed |
| 2026-11-21 | Phase 05 | Implemented NetworkSpeedCalculator actor, monotonic elapsed-time arithmetic, independent download/upload calculation, baseline management, counter decrease protection, ADR-033, and 12 unit test suites (87 assertions passing) | Completed |
| 2026-11-21 | Phase 06 | Implemented ByteFormatter and SpeedFormatter, base-1000 SI decimal scaling, up to 2 decimal places with trailing zero trimming, 0 KB/s zero display, ADR-034, and 13 unit test suites (111 assertions passing) | Completed |
| 2026-11-21 | Phase 07 | Implemented DominantDirectionEngine actor, DirectionDecision, DirectionSwitchingConfiguration, 10% relative margin, 10 KB/s noise floor, 2-sample confirmation, download idle default, IEEE 754 micro-epsilon handling, ADR-035, and 14 unit test suites (124 assertions passing) | Completed |
| 2026-11-21 | Phase 08 | Implemented native NSStatusItem integration via MenuBarManager, MenuBarRenderer, MenuBarContent, MenuBarMenuBuilder, MenuBarAppearance, official logo and AppIcon.icns integration, ADR-036, and 16 unit test suites (140 assertions passing) | Completed |
| 2026-11-22 | Phase 09 | Implemented all 4 display modes, dynamic style switching, manual pinning, and 18 unit test suites (160 assertions passing) | Completed |
| 2026-11-22 | Phase 10 | Implemented native SwiftUI SettingsView, SettingsManager, PreferencesStore persistence, and 20 unit test suites (188 assertions passing) | Completed |
| 2026-11-22 | Phase 11 | Implemented application startup coordination, single sampling-task lifecycle, SMAppService LoginItemManager, and 22 unit test suites (208 assertions passing) | Completed |
| 2026-11-22 | Phase 12 | Authored offline markdown guides, DocumentReaderView, AboutView, bundle resource integration, and 23 unit test suites (218 assertions passing) | Completed |
| 2026-11-22 | Phase 13 | Implemented error handling, sleep/gap resets, counter decrease protection, redundant render suppression, and 24 unit test suites (220 assertions passing) | Completed |
| 2026-11-22 | Phase 14 | Executed comprehensive testing & compatibility audit, 25 test suites (249 assertions passing), Universal Binary validation, and produced TESTING_REPORT.md | Completed |

Future entries should describe actual code, configuration, testing, or release changes.

---

## 13. Next Development Tasks

Phase 14 is completed and verified. The immediate development sequence for Phase 15 (Universal Binary & DMG Packaging) is:

1. Configure Release build settings and finalize distribution properties.
2. Verify production Universal Binary packaging (`arm64` + `x86_64`) with embedded resources and documentation.
3. Prepare the Applications symlink and DMG volume assets (`.VolumeIcon.icns`, background image).
4. Generate the standalone, installable `ARRY-Network-Counter.dmg`.
5. Verify clean drag-and-drop installation into `/Applications` without development tools.

---

## 14. Project Status Update Rules

Update this document whenever:

- A new phase starts.
- A phase is completed.
- A feature is implemented.
- A test is passed or fails.
- A bug is discovered.
- A blocker appears or is resolved.
- A technical decision changes.
- The build configuration changes.
- A release artifact is generated.

### Status Definitions

| Status | Meaning |
|---|---|
| Not Started | Work has not begun |
| In Progress | Implementation is actively underway |
| Blocked | Work cannot proceed due to a dependency or issue |
| Completed | Implementation and acceptance criteria verified |
| Deferred | Intentionally postponed |
| Not Applicable | Not required for the final scope |

Never mark a phase completed based only on code generation or an unverified implementation.

---

## 15. Final Project Completion Criteria

The project can be marked completed when:

- [ ] All 16 implementation phases are completed.
- [ ] All required display modes work correctly.
- [ ] Real network download speed is displayed.
- [ ] Real network upload speed is displayed.
- [ ] Automatic direction switching works reliably.
- [ ] Settings persist after application restart.
- [ ] Launch at Login works.
- [ ] Documentation is available offline.
- [ ] No known release-blocking defects remain.
- [ ] Universal Binary is verified.
- [ ] DMG installation is verified.
- [ ] Application runs without development tools.
- [ ] Signing and notarization status is verified and documented where applicable.
- [ ] Privacy and scope requirements are satisfied.

### Final Deliverable

```text
ARRY-Network-Counter.dmg
```

### Final Expected User Experience

1. Open the DMG.
2. Drag the application into Applications.
3. Launch ARRY Network Counter.
4. View real-time download and upload speeds in the macOS menu bar.
5. Select the preferred display mode.
6. Optionally enable Launch at Login.

No backend, database, account, cloud service, or development environment should be required on the destination Mac.

---

**Document:** `CURRENT_STATUS.md`  
**Project:** ARRY Network Counter (ANC)  
**Organization:** ARRRY  
**Last Updated:** 2026-11-21  
**Project Stage:** Documentation & Planning  
**Overall Status:** Ready for Development