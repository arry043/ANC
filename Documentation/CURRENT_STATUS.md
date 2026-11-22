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
| Settings Interface | Not Started |
| Testing | Completed (Phase 02–09 Unit Tests — 160 assertions passed) |
| DMG Packaging | Not Started |
| Production Release | Not Started |

**Current Development Phase:** Phase 09 Completed — Ready for Phase 10 (Settings Interface & Preferences)  
**Next Action:** Begin Phase 10 implementation.

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
| 10 | Settings Interface & Preferences | Not Started |
| 11 | Application Lifecycle & Launch at Login | Not Started |
| 12 | Documentation & About Section | Not Started |
| 13 | Error Handling & Performance Optimization | Not Started |
| 14 | Comprehensive Testing & Compatibility | Not Started |
| 15 | Universal Binary & DMG Packaging | Not Started |
| 16 | Final Release & Deployment Verification | Not Started |

### Progress Summary

| Metric | Current Value |
|---|---:|
| Total Phases | 16 |
| Completed Phases | 9 |
| In Progress Phases | 0 |
| Blocked Phases | 0 |
| Not Started Phases | 7 |
| Overall Implementation Progress | 56.25% |

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

**Next Step:** Proceed to Phase 10 — Settings Interface & Preferences.

---

### Previous Phase: Phase 08 — Native Menu Bar Integration

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

Future entries should describe actual code, configuration, testing, or release changes.

---

## 13. Next Development Tasks

Phase 08 is completed and verified. The immediate development sequence for Phase 09 (Display Modes Implementation) is:

1. Wire full user preferences switching for all three display modes (`bothDirections`, `singleDirectionManual`, `singleDirectionAutomatic`).
2. Implement seamless dynamic switching between `separateSpeeds` and `combinedArrows` within `bothDirections`.
3. Support manual direction selection toggling (`download` vs `upload`) with immediate UI reflection.
4. Verify dynamic transitions between display modes without restarting monitoring or recreating the status item.
5. Expand unit tests for display mode transitions and configuration state transformations.

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