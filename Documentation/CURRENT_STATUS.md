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
| Network Monitoring | Dominant Direction Logic Completed (Phase 07) |
| Menu Bar Integration | Not Started |
| Settings Interface | Not Started |
| Testing | Completed (Phase 02–07 Unit Tests — 124 assertions passed) |
| DMG Packaging | Not Started |
| Production Release | Not Started |

**Current Development Phase:** Phase 07 Completed — Ready for Phase 08 (Native Menu Bar Integration)  
**Next Action:** Begin Phase 08 implementation.

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
| 08 | Native Menu Bar Integration | Not Started |
| 09 | Display Modes Implementation | Not Started |
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
| Completed Phases | 7 |
| In Progress Phases | 0 |
| Blocked Phases | 0 |
| Not Started Phases | 9 |
| Overall Implementation Progress | 43.75% |

Documentation completion is tracked separately and does not count as implementation progress.

---

## 5. Current Development Focus

### Phase 07 — Dominant Direction & Switching Logic

**Priority:** High  
**Status:** Completed

#### Objective

Implement a reusable, deterministic decision engine (`DominantDirectionEngine`) responsible for selecting whether Download or Upload is currently the dominant network traffic direction for automatic display modes (`singleDirectionAutomatic` and `combinedArrows`), incorporating 10% relative switching hysteresis, 10 KB/s absolute noise floor suppression, 2 consecutive sample confirmation, download default idle direction, IEEE 754 micro-epsilon handling, and integration with `ApplicationCoordinator`.

#### Completed Tasks

- [x] Implement `DirectionDecision` value model with direction, switch flag, candidate direction, and confirmation count.
- [x] Implement `DirectionSwitchingConfiguration` with centralized defaults (10% relative margin, 10,000 B/s noise floor, 2 consecutive samples, .download default).
- [x] Implement `DominantDirectionEngine` actor with thread-safe state evaluation, reset, and configuration updates.
- [x] Implement 10% relative hysteresis threshold ($S_{\text{opposite}} \ge S_{\text{current}} \times (1 + \text{relativeMargin})$).
- [x] Implement absolute noise floor threshold ($S_{\text{opposite}} - S_{\text{current}} \ge \text{absoluteThresholdBytesPerSecond}$).
- [x] Require 2 consecutive qualifying samples before committing a direction switch.
- [x] Reset pending candidate and streak count immediately if an intermediate sample fails to qualify.
- [x] Revert immediately to `.download` default when both traffic rates are idle ($\le 0$ B/s).
- [x] Apply IEEE 754 micro-epsilon ($1\times 10^{-7}$) tolerance to eliminate binary floating-point rounding inaccuracies on exact boundary multiples.
- [x] Integrate `DominantDirectionEngine` into `ApplicationCoordinator` with `@Published public private(set) var dominantDirection`.
- [x] Codify hysteresis and noise floor parameters in `ADR-035`.
- [x] Implement 12 comprehensive unit tests in `Tests/DominantDirectionEngineTests.swift`.
- [x] Implement live coordinator dominant direction switching and disconnection reset tests in `Tests/ApplicationCoordinatorTests.swift`.

#### Deliverables Produced

- Dominant direction engine: `ARRYNetworkCounter/Services/Monitoring/DominantDirectionEngine.swift`.
- Direction decision and configuration models: `DirectionDecision` and `DirectionSwitchingConfiguration`.
- Coordinator integration: `ApplicationCoordinator.swift` (`dominantDirection`, initialization, observation task evaluation, reset on disconnection/stop).
- Architecture Decision Record: `ADR-035 — Dominant Direction Hysteresis and Noise Threshold Parameters`.
- Unit test suite: `Tests/DominantDirectionEngineTests.swift` (12 assertions).
- Updated coordinator test suite: `Tests/ApplicationCoordinatorTests.swift` (10 assertions).
- Updated test runner: `Tests/TestRunner.swift` (124 assertions passing across 14 test suites).

#### Completion Verification

- [x] Correct dominant direction is selected for clear download and clear upload traffic.
- [x] Relative margin hysteresis (10%) prevents premature switching.
- [x] Absolute noise floor (10 KB/s) suppresses trickle traffic and micro-oscillations.
- [x] Two consecutive samples required to commit direction switch; interrupted streaks reset cleanly.
- [x] Idle traffic immediately reverts direction to `.download`.
- [x] Near-equal traffic oscillations remain completely stable without visual flapping.
- [x] Disconnection and coordinator shutdown safely reset direction to `.download`.
- [x] 100% of unit tests pass (124 assertions across 14 test suites with 0 failures in 99.94 ms).
- [x] Universal Binary builds (`arm64` and `x86_64`) compile cleanly for Debug and Release.

**Next Step:** Proceed to Phase 08 — Native Menu Bar Integration.

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
- Automated test suite and test runner: `Tests/`, `Scripts/test.sh` (124 assertion checks across 14 test suites).

### Verified Functionality

- Debug and Release application bundles build cleanly without warnings or errors.
- Universal Binary executable verified with `lipo -info` containing both `arm64` and `x86_64` architecture slices.
- Menu bar utility configuration (`LSUIElement = true`) verified via `plutil`.
- Application launch verified on macOS without crashing for both Debug and Release bundles.
- Full Phase 02 through Phase 07 unit test suites pass: 124 assertions verified across 14 test suites with 0 failures in 99.94 ms.
- Empirical verification of `SystemNetworkInterfaceProvider` against live macOS `netstat -ib`: 100% byte-for-byte counter match on active Wi-Fi interface (`en0`).
- Safe C memory deallocation verified with `freeifaddrs()` invoked on every code path via Swift `defer`.
- Speed calculation verified across normal, fractional, irregular, small intervals, large counters, zero traffic, counter decreases, interface transitions, and disconnection lifecycles.
- Formatting verified across all units, boundary values, decimal precision, trailing-zero stripping, zero display (`0 KB/s`), and POSIX locale independence.
- Dominant direction switching verified across clear download/upload dominance, relative margin thresholds, absolute noise floors, consecutive sample confirmation, streak interruption, idle reversion, near-equal oscillation stability, and coordinator lifecycle resets.

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

Future entries should describe actual code, configuration, testing, or release changes.

---

## 13. Next Development Tasks

Phase 07 is completed and verified. The immediate development sequence for Phase 08 (Native Menu Bar Integration) is:

1. Create `MenuBarManager` (`NSStatusItem` lifecycle, ownership, menu bar item creation and destruction).
2. Create `MenuBarRenderer` (attributed string rendering, dynamic width measurement, system font styling).
3. Connect `ApplicationCoordinator` published speed and direction states to menu bar item title updates.
4. Support menu item actions (About, Settings, Quit).
5. Verify clean display on both light and dark menu bar appearances and various screen resolutions.

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