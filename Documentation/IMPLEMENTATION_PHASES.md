# IMPLEMENTATION_PHASES.md

# ARRY Network Counter (ANC)

**Organization:** ARRRY  
**Application:** ARRY Network Counter  
**Short Name:** ANC  
**Platform:** macOS  
**Technology:** Swift 6, SwiftUI, AppKit  
**Distribution:** DMG  
**Development Approach:** Phase-Based Implementation  
**Status:** Ready for Development

---

## 1. Development Overview

ARRY Network Counter will be developed through clearly defined implementation phases.

Each phase must produce a working, testable result before the next dependent phase begins.

### Development Principles

- Follow `PROJECT_REQUIREMENTS.md` as the product specification.
- Follow `TECHNICAL_ARCHITECTURE.md` as the implementation blueprint.
- Preserve the minimal product scope.
- Prefer native Apple frameworks.
- Avoid unnecessary dependencies.
- Write modular, maintainable, and testable Swift code.
- Test each component before integrating it.
- Do not leave placeholder implementations in completed phases.
- Do not mark a phase complete without satisfying its acceptance criteria.

### Phase Summary

| Phase | Name | Priority | Status |
|---|---|---|---|
| 01 | Project Initialization & Configuration | Critical | Completed |
| 02 | Core Models & Application Foundation | Critical | Completed |
| 03 | Network Path Detection | Critical | Completed |
| 04 | Network Interface Statistics | Critical | Completed |
| 05 | Network Speed Calculation Engine | Critical | Completed |
| 06 | Speed Formatting Engine | High | Completed |
| 07 | Dominant Direction & Switching Logic | High | Not Started |
| 08 | Native Menu Bar Integration | Critical |
| 09 | Display Modes Implementation | Critical |
| 10 | Settings Interface & Preferences | High |
| 11 | Application Lifecycle & Launch at Login | High |
| 12 | Documentation & About Section | Medium |
| 13 | Error Handling & Performance Optimization | High |
| 14 | Comprehensive Testing & Compatibility | Critical |
| 15 | Universal Binary & DMG Packaging | Critical |
| 16 | Final Release & Deployment Verification | Critical |

---

# 2. Implementation Phases

## Phase 01 — Project Initialization & Configuration

**Priority:** Critical  
**Status:** Completed

### Objective

Initialize the native macOS application project with the agreed technology stack and development structure.

### Tasks

- [x] Create a new native macOS application in Xcode.
- [x] Configure Swift 6.
- [x] Configure SwiftUI and AppKit integration.
- [x] Set the application name to `ARRY Network Counter`.
- [x] Configure the bundle identifier.
- [x] Configure ARRRY as the organization.
- [x] Set the application deployment target.
- [x] Configure Universal Binary architectures (`arm64`, `x86_64`).
- [x] Configure the application as a menu bar utility.
- [x] Configure the initial asset catalog.
- [x] Establish the project directory structure.
- [x] Initialize Git and `.gitignore`.
- [x] Create the documentation directory.
- [x] Verify the initial application build.

### Deliverables

- Working Xcode project (`ARRYNetworkCounter.xcodeproj`).
- Configured Swift development environment (Swift 6.4.2).
- Initial application bundle (`build/Debug/ARRY Network Counter.app` & `build/Release/ARRY Network Counter.app`).
- Established project structure aligned with `TECHNICAL_ARCHITECTURE.md`.

### Completion Criteria

- [x] Project builds successfully.
- [x] Application launches on the development Mac.
- [x] No unnecessary third-party dependencies.
- [x] Project configuration matches the architecture document.

---

## Phase 02 — Core Models & Application Foundation

**Priority:** Critical  
**Status:** Completed

### Objective

Implement the core data models, protocols, and application coordination structure.

### Tasks

- [x] Implement `NetworkSpeed`.
- [x] Implement `NetworkSnapshot`.
- [x] Implement `NetworkInterface`.
- [x] Implement `DisplayMode`.
- [x] Implement `BothDirectionsStyle`.
- [x] Implement `NetworkDirection`.
- [x] Implement `AppPreferences`.
- [x] Define network monitoring protocols.
- [x] Define preferences storage protocols.
- [x] Implement the application coordinator.
- [x] Establish appropriate actor and `MainActor` isolation.
- [x] Define shared application configuration constants.

### Deliverables

- Core Swift models (`NetworkSpeed`, `NetworkSnapshot`, `NetworkInterface`, `DisplayMode`, `BothDirectionsStyle`, `NetworkDirection`, `AppPreferences`).
- Application coordination foundation (`ApplicationCoordinator`, `AppConfiguration`).
- Protocol definitions (`NetworkMonitoring`, `PreferencesStoring`).
- Initial model and coordinator unit tests (`Tests/`, `Scripts/test.sh`).

### Completion Criteria

- [x] All core models compile.
- [x] Models have clearly defined responsibilities.
- [x] Display modes are represented using strongly typed models.
- [x] No UI-specific logic exists inside network calculation models.
- [x] Unit tests pass (27/27 assertions across 6 test suites).

---

## Phase 03 — Network Path Detection

**Priority:** Critical  
**Status:** Completed

### Objective

Implement native macOS network path monitoring and connectivity change detection.

### Tasks

- [x] Integrate Apple's `Network.framework`.
- [x] Implement `NetworkPathManager`.
- [x] Implement `NWPathMonitor` lifecycle management.
- [x] Detect available network paths.
- [x] Detect network connectivity changes.
- [x] Identify available interface types.
- [x] Handle connected and disconnected states.
- [x] Handle network path changes.
- [x] Publish path changes to the monitoring coordinator.
- [x] Ensure monitoring can be stopped cleanly.

### Deliverables

- Working network path monitor (`NetworkPathManager.swift`).
- Connectivity state management (`NetworkPathState.swift`).
- Interface information available to the selection layer.
- Unit test suite for path state, lifecycle, and coordinator integration (`Tests/NetworkPathStateTests.swift`, `Tests/NetworkPathManagerTests.swift`).

### Completion Criteria

- [x] Wi-Fi connectivity is detected.
- [x] Ethernet connectivity is detected where available.
- [x] Disconnection is detected.
- [x] Reconnection is detected.
- [x] Interface changes trigger re-evaluation.
- [x] No duplicate monitoring instances are created.
- [x] Monitoring shuts down cleanly.

---

## Phase 04 — Network Interface Statistics

**Priority:** Critical  
**Status:** Completed

### Objective

Retrieve actual received and transmitted byte counters from macOS network interfaces.

### Tasks

- [x] Implement `NetworkInterfaceProvider`.
- [x] Integrate `getifaddrs()`.
- [x] Retrieve `AF_LINK` interface records.
- [x] Read `ifi_ibytes`.
- [x] Read `ifi_obytes`.
- [x] Implement safe access to the underlying system structures.
- [x] Release allocated interface resources correctly.
- [x] Implement `NetworkInterfaceSelector`.
- [x] Identify the interface associated with the usable network path.
- [x] Exclude loopback interfaces.
- [x] Handle missing or unavailable interfaces.
- [x] Avoid blindly summing overlapping physical and virtual interfaces.
- [x] Handle VPN and other virtual interfaces explicitly.
- [x] Re-evaluate the selected interface after network changes.

### Deliverables

- Actual network interface byte-counter provider (`NetworkInterfaceProvider.swift`).
- Interface selection mechanism (`NetworkInterfaceSelector.swift`).
- Network snapshot data pipeline (`NetworkSnapshot` and `NetworkInterfaceStatistics`).

### Completion Criteria

- [x] Received byte counters are retrieved correctly.
- [x] Transmitted byte counters are retrieved correctly.
- [x] The selected interface is associated with the current network path.
- [x] Loopback traffic is excluded.
- [x] Interface changes are handled safely.
- [x] Counter retrieval failures do not crash the application.
- [x] No duplicate traffic counting from blindly aggregating interfaces.

**Important:** Verify the interface selection strategy on real macOS configurations, particularly Wi-Fi, Ethernet, VPN, and virtual interfaces. Do not assume interface names or counter semantics without testing.

---

## Phase 05 — Network Speed Calculation Engine

**Priority:** Critical  
**Status:** Completed

### Objective

Implement accurate download and upload speed calculations using consecutive network counter snapshots.

### Tasks

- [x] Implement `NetworkSpeedCalculator`.
- [x] Capture the initial network snapshot.
- [x] Store the previous received byte count.
- [x] Store the previous transmitted byte count.
- [x] Record monotonic sample timestamps.
- [x] Calculate actual elapsed time.
- [x] Calculate download speed.
- [x] Calculate upload speed.
- [x] Handle the first sample.
- [x] Handle zero elapsed time.
- [x] Handle negative or invalid elapsed intervals.
- [x] Handle counter decreases and resets.
- [x] Reset the baseline when the selected interface changes.
- [x] Reset the baseline after disconnection.
- [x] Resume calculation after reconnection.
- [x] Ensure no negative speed is produced.

### Calculation

```text
Download Speed =
(Current Received Bytes - Previous Received Bytes)
/
Elapsed Seconds

Upload Speed =
(Current Transmitted Bytes - Previous Transmitted Bytes)
/
Elapsed Seconds
```

### Deliverables

- Working speed calculation engine (`NetworkSpeedCalculator.swift`).
- Reliable network speed measurements (`SpeedMeasurement` and `SpeedCalculationResult`).
- Unit tests for calculation scenarios (`NetworkSpeedCalculatorTests.swift`).

### Completion Criteria

- [x] Download speed is calculated correctly.
- [x] Upload speed is calculated correctly.
- [x] Actual elapsed time is used.
- [x] First sample establishes a baseline.
- [x] Counter resets do not produce negative values.
- [x] Interface changes do not produce artificial speed spikes.
- [x] Reconnection establishes a new baseline.
- [x] Unit tests pass.

---

## Phase 06 — Speed Formatting Engine

**Priority:** High  
**Status:** Completed

### Objective

Convert raw byte-per-second measurements into readable menu bar values.

### Tasks

- [x] Implement `ByteFormatter`.
- [x] Implement `SpeedFormatter`.
- [x] Support KB/s.
- [x] Support MB/s.
- [x] Support GB/s.
- [x] Support TB/s.
- [x] Implement automatic unit selection.
- [x] Implement consistent decimal precision.
- [x] Remove unnecessary trailing zeros.
- [x] Handle zero speed.
- [x] Handle very small values.
- [x] Handle very large values.
- [x] Prevent negative formatted values.

### Formatting Examples

| Raw Speed | Expected Display |
|---:|---|
| 0 B/s | 0 KB/s |
| 450,250 B/s | 450.25 KB/s |
| 2,450,000 B/s | 2.45 MB/s |
| 1,250,000,000 B/s | 1.25 GB/s |
| 1,200,000,000,000 B/s | 1.20 TB/s |

### Deliverables

- Reusable speed formatter (`ByteFormatter.swift` and `SpeedFormatter.swift`).
- Consistent unit conversion (SI base 1000 per ADR-014).
- Formatting unit tests (`SpeedFormatterTests.swift`).

### Completion Criteria

- [x] All supported units work correctly.
- [x] Decimal conversion uses base 1000.
- [x] Output is readable.
- [x] Zero is displayed as `0 KB/s`.
- [x] No unnecessary trailing zeros.
- [x] Unit boundary tests pass.

---

## Phase 07 — Dominant Direction & Switching Logic

**Priority:** High  
**Status:** Completed

### Objective

Implement the common direction-selection engine used by automatic display modes.

### Tasks

- [x] Implement `DominantDirectionEngine`.
- [x] Compare current download and upload speeds.
- [x] Identify the dominant direction.
- [x] Implement switching hysteresis.
- [x] Implement an absolute noise threshold.
- [x] Require confirmation across consecutive valid samples.
- [x] Preserve the current direction when speeds are close.
- [x] Handle idle traffic.
- [x] Use Download as the default idle direction.
- [x] Ensure responsive direction changes.
- [x] Make thresholds centrally configurable for testing.

### Initial Switching Policy

| Condition | Behavior |
|---|---|
| Download clearly dominates | Select Download |
| Upload clearly dominates | Select Upload |
| Speeds are close | Preserve current direction |
| Small traffic fluctuations | Avoid unnecessary switching |
| Both directions idle | Select Download |
| Network reconnects | Re-establish direction state safely |

Initial tuning targets:

- Relative switching margin: approximately 10%.
- Confirmation: two consecutive valid samples.
- Additional absolute threshold: used to suppress low-rate noise.

These are initial engineering defaults, not user-facing settings. Validate them during real-world testing.

### Deliverables

- Reusable dominant direction engine.
- Stable automatic switching behavior.
- Unit tests for direction transitions.

### Completion Criteria

- [x] Correct dominant direction is selected.
- [x] Both automatic display modes can use the same engine.
- [x] No excessive switching occurs near equal speeds.
- [x] Direction changes remain responsive.
- [x] Idle behavior is correct.
- [x] Unit tests pass.

---

## Phase 08 — Native Menu Bar Integration

**Priority:** Critical  
**Status:** Completed

### Objective

Implement the native macOS menu bar status item using AppKit.

### Tasks

- [x] Implement `MenuBarManager`.
- [x] Create an `NSStatusItem`.
- [x] Implement `MenuBarRenderer`.
- [x] Render download arrows.
- [x] Render upload arrows.
- [x] Apply direction-specific arrow colors.
- [x] Render speed text.
- [x] Configure readable font sizing.
- [x] Support Light Mode.
- [x] Support Dark Mode.
- [x] Configure status item sizing.
- [x] Update menu bar content dynamically.
- [x] Create the minimal native context menu.
- [x] Add Settings menu item.
- [x] Add Quit menu item.
- [x] Ensure the status item is removed on termination.

### Display Examples

```text
↓ 2.45 MB/s    ↑ 120 KB/s

↓ ↑ 2.45 MB/s

↓ 2.45 MB/s

↑ 120 KB/s
```

### Deliverables

- Native menu bar status item.
- Dynamic text rendering.
- Settings and Quit access.

### Completion Criteria

- [x] Menu bar item appears after application launch.
- [x] Arrows and text render correctly.
- [x] Download arrow is green.
- [x] Upload arrow is blue.
- [x] Text is readable in both appearance modes.
- [x] Menu bar updates without opening a window.
- [x] Settings and Quit actions work.
- [x] No unnecessary Dock icon appears during normal operation.

---

## Phase 09 — Display Modes Implementation

**Priority:** Critical  
**Status:** Not Started

### Objective

Integrate all three display modes and both sub-options of Both Directions.

### Tasks

**Both Directions — Separate Speeds**

- [ ] Display both arrows.
- [ ] Display download speed independently.
- [ ] Display upload speed independently.
- [ ] Apply separate arrow colors.
- [ ] Update both values dynamically.

**Both Directions — Combined Arrows**

- [ ] Always display both arrows.
- [ ] Display only one numerical speed.
- [ ] Use the dominant direction engine.
- [ ] Switch the numerical speed when dominance changes.
- [ ] Display `↓ ↑ 0 KB/s` when idle.

**Single Direction — Manual**

- [ ] Implement Download selection.
- [ ] Implement Upload selection.
- [ ] Display only the selected direction.
- [ ] Keep the selected direction until changed.

**Single Direction — Automatic**

- [ ] Display only one arrow.
- [ ] Use the dominant direction engine.
- [ ] Switch between Download and Upload.
- [ ] Display `↓ 0 KB/s` when idle.

### Deliverables

- All required display modes.
- Fully integrated rendering logic.
- Mode transition tests.

### Completion Criteria

- [ ] Both Directions — Separate works.
- [ ] Both Directions — Combined works.
- [ ] Single Direction — Manual Download works.
- [ ] Single Direction — Manual Upload works.
- [ ] Single Direction — Automatic works.
- [ ] All modes update using real network measurements.
- [ ] Changing modes does not restart network monitoring.
- [ ] No incorrect or additional speed values are displayed.

---

## Phase 10 — Settings Interface & Preferences

**Priority:** High  
**Status:** Not Started

### Objective

Implement the compact native Settings window and persistent user preferences.

### Tasks

- [ ] Implement `SettingsManager`.
- [ ] Implement `PreferencesStore`.
- [ ] Implement `SettingsView`.
- [ ] Implement Display Settings.
- [ ] Add Both Directions configuration.
- [ ] Add Separate Speeds selection.
- [ ] Add Combined Arrows selection.
- [ ] Add Single Direction — Manual.
- [ ] Add Download selection.
- [ ] Add Upload selection.
- [ ] Add Single Direction — Automatic.
- [ ] Implement Launch at Login toggle.
- [ ] Add documentation navigation.
- [ ] Persist display preferences using UserDefaults.
- [ ] Restore preferences after application relaunch.
- [ ] Apply setting changes immediately.

### Preference Keys

```text
displayMode
bothDirectionsStyle
manualDirection
launchAtLogin
```

### Deliverables

- Complete Settings window.
- Persistent preferences.
- Immediate settings updates.

### Completion Criteria

- [ ] All display options are accessible.
- [ ] Only relevant options are shown for the selected mode.
- [ ] Settings are saved correctly.
- [ ] Settings persist after relaunch.
- [ ] Invalid or missing preferences use safe defaults.
- [ ] Display updates immediately after configuration changes.
- [ ] Settings remain compact and easy to use.

---

## Phase 11 — Application Lifecycle & Launch at Login

**Priority:** High  
**Status:** Not Started

### Objective

Complete application lifecycle handling and optional macOS login launch support.

### Tasks

- [ ] Implement application startup coordination.
- [ ] Start network monitoring on application launch.
- [ ] Ensure only one sampling task exists.
- [ ] Implement monitoring task cancellation.
- [ ] Handle application termination.
- [ ] Implement `LoginItemManager`.
- [ ] Integrate `ServiceManagement`.
- [ ] Use `SMAppService` where supported.
- [ ] Implement login launch registration.
- [ ] Implement login launch unregistration.
- [ ] Reflect registration state in Settings.
- [ ] Handle registration errors.
- [ ] Ensure the application works without login launch.

### Deliverables

- Stable application lifecycle.
- Optional Launch at Login functionality.
- Reliable monitoring startup and shutdown.

### Completion Criteria

- [ ] Monitoring starts automatically on launch.
- [ ] Duplicate sampling tasks are prevented.
- [ ] Monitoring stops on Quit.
- [ ] Login launch can be enabled.
- [ ] Login launch can be disabled.
- [ ] Registration failures do not crash the application.
- [ ] No unnecessary background process remains after termination.

---

## Phase 12 — Documentation & About Section

**Priority:** Medium  
**Status:** Not Started

### Objective

Implement offline documentation and application information inside Settings.

### Tasks

- [ ] Create Setup Guide.
- [ ] Document DMG installation.
- [ ] Document copying the app into Applications.
- [ ] Document first-launch security approval where applicable.
- [ ] Document Settings access.
- [ ] Document Launch at Login.
- [ ] Create Usage Guide.
- [ ] Explain all display modes.
- [ ] Explain automatic direction switching.
- [ ] Explain supported units.
- [ ] Explain measurement limitations.
- [ ] Create Terms and Conditions.
- [ ] Create Privacy Policy.
- [ ] Implement About ANC.
- [ ] Display application version.
- [ ] Display ARRRY branding.
- [ ] Display copyright information.
- [ ] Bundle documentation with the application.

### Deliverables

- Complete offline documentation.
- About section.
- Documentation navigation inside Settings.

### Completion Criteria

- [ ] All documentation is accessible offline.
- [ ] Setup instructions are accurate.
- [ ] Display modes are clearly explained.
- [ ] Privacy statements match the actual implementation.
- [ ] Version and organization information are correct.
- [ ] No placeholder documentation remains.

---

## Phase 13 — Error Handling & Performance Optimization

**Priority:** High  
**Status:** Not Started

### Objective

Improve stability, resource efficiency, and recovery from unexpected system conditions.

### Tasks

- [ ] Review all network error paths.
- [ ] Handle interface statistics retrieval failures.
- [ ] Handle network disconnections.
- [ ] Handle network reconnections.
- [ ] Handle interface changes.
- [ ] Handle invalid counter snapshots.
- [ ] Handle unexpected sampling delays.
- [ ] Review task cancellation.
- [ ] Review actor isolation.
- [ ] Prevent duplicate monitoring tasks.
- [ ] Prevent unnecessary menu bar updates.
- [ ] Reduce unnecessary allocations.
- [ ] Review memory usage.
- [ ] Review CPU consumption.
- [ ] Verify no traffic history is persisted.
- [ ] Verify no external network requests are made by the monitoring implementation.

### Deliverables

- Improved application stability.
- Optimized monitoring pipeline.
- Verified error recovery.

### Completion Criteria

- [ ] Temporary network errors do not crash the app.
- [ ] Monitoring recovers after reconnection.
- [ ] No duplicate sampling tasks.
- [ ] No unnecessary continuous CPU activity.
- [ ] No persistent traffic history.
- [ ] No unnecessary external dependencies or requests.
- [ ] Application remains stable during extended operation.

---

## Phase 14 — Comprehensive Testing & Compatibility

**Priority:** Critical  
**Status:** Not Started

### Objective

Perform complete unit, integration, manual, and compatibility testing.

### Tasks

**Unit Testing**

- [ ] Test speed calculations.
- [ ] Test counter reset handling.
- [ ] Test elapsed-time calculations.
- [ ] Test byte formatting.
- [ ] Test unit boundaries.
- [ ] Test dominant direction selection.
- [ ] Test switching hysteresis.
- [ ] Test settings persistence.
- [ ] Test interface selection.

**Integration Testing**

- [ ] Test interface statistics to speed calculation.
- [ ] Test speed calculation to formatter.
- [ ] Test formatter to menu bar.
- [ ] Test all display modes.
- [ ] Test network path changes.
- [ ] Test Settings updates.
- [ ] Test application lifecycle.

**Manual Testing**

- [ ] Test Wi-Fi.
- [ ] Test Ethernet where available.
- [ ] Test VPN.
- [ ] Test network disconnection.
- [ ] Test network reconnection.
- [ ] Test switching between interfaces.
- [ ] Test Light Mode.
- [ ] Test Dark Mode.
- [ ] Test long-running sessions.
- [ ] Test launch at login.
- [ ] Test clean application termination.

**Compatibility Testing**

- [ ] Test Apple Silicon build.
- [ ] Test Intel build where hardware is available.
- [ ] Verify minimum macOS version compatibility.
- [ ] Verify Universal Binary architecture slices.
- [ ] Verify native application behavior after installation.

### Deliverables

- Complete test suite.
- Testing report.
- Verified application behavior.

### Completion Criteria

- [ ] All required unit tests pass.
- [ ] Integration tests pass.
- [ ] All display modes work correctly.
- [ ] Network transitions work correctly.
- [ ] No known critical or high-severity defects remain.
- [ ] Target architecture compatibility is verified.
- [ ] Release blockers are resolved.

---

## Phase 15 — Universal Binary & DMG Packaging

**Priority:** Critical  
**Status:** Not Started

### Objective

Prepare the production application and create an installable DMG that works on supported Macs without development tools.

### Tasks

- [ ] Configure Release build settings.
- [ ] Build for `arm64`.
- [ ] Build for `x86_64`.
- [ ] Create the Universal Binary.
- [ ] Verify architecture slices.
- [ ] Configure application bundle metadata.
- [ ] Configure application version.
- [ ] Configure bundle identifier.
- [ ] Verify bundled documentation.
- [ ] Prepare the Applications shortcut.
- [ ] Create the DMG.
- [ ] Configure DMG presentation.
- [ ] Verify the DMG opens.
- [ ] Verify the app can be dragged into Applications.
- [ ] Verify the installed app launches independently.
- [ ] Confirm Xcode and development tools are not required on the destination Mac.

### Expected Output

```text
dist/
│
├── ARRY Network Counter.app
│
└── ARRY-Network-Counter.dmg
```

### Code Signing & Notarization

- [ ] Configure Developer ID signing when credentials are available.
- [ ] Enable hardened runtime as required.
- [ ] Sign the application.
- [ ] Submit for Apple notarization.
- [ ] Staple the notarization ticket.
- [ ] Sign and verify the DMG as appropriate.
- [ ] Verify Gatekeeper behavior.

If signing or notarization credentials are unavailable, document the limitation and produce a clearly identified personal-testing build. Do not claim that an unsigned build is notarized.

### Deliverables

- Universal application bundle.
- Installable DMG.
- Build and verification scripts.

### Completion Criteria

- [ ] DMG is generated successfully.
- [ ] DMG installation works.
- [ ] Application runs from Applications.
- [ ] No development environment is required.
- [ ] Intended architecture slices are verified.
- [ ] Signing and notarization status is accurately documented.

---

## Phase 16 — Final Release & Deployment Verification

**Priority:** Critical  
**Status:** Not Started

### Objective

Complete the final release audit and prepare ANC for distribution.

### Tasks

- [ ] Perform a clean installation test.
- [ ] Test on a Mac without the development environment.
- [ ] Verify all display modes.
- [ ] Verify network speed accuracy.
- [ ] Verify menu bar appearance.
- [ ] Verify Settings.
- [ ] Verify Launch at Login.
- [ ] Verify Quit behavior.
- [ ] Verify documentation.
- [ ] Verify privacy implementation.
- [ ] Verify no backend or database dependencies.
- [ ] Verify no unnecessary permissions.
- [ ] Verify application version.
- [ ] Verify DMG filename.
- [ ] Verify code signing and notarization where configured.
- [ ] Prepare final release notes.
- [ ] Archive the final release artifacts.

### Deliverables

- Release-ready ANC application.
- Final DMG installer.
- Release notes.
- Final verification report.

### Completion Criteria

- [ ] All required functionality is implemented.
- [ ] All critical tests pass.
- [ ] No known release-blocking defects remain.
- [ ] Installation instructions are complete.
- [ ] Distribution artifacts are verified.
- [ ] Final release status is documented.

---

# 3. Phase Dependencies

The phases should follow this dependency structure.

```text
Phase 01: Project Initialization
        |
        v
Phase 02: Core Models
        |
        v
Phase 03: Network Path Detection
        |
        v
Phase 04: Interface Statistics
        |
        v
Phase 05: Speed Calculation
        |
        v
Phase 06: Speed Formatting
        |
        v
Phase 07: Dominant Direction
        |
        v
Phase 08: Menu Bar Integration
        |
        v
Phase 09: Display Modes
        |
        v
Phase 10: Settings & Preferences
        |
        v
Phase 11: Lifecycle & Launch at Login
        |
        v
Phase 12: Documentation
        |
        v
Phase 13: Error Handling & Optimization
        |
        v
Phase 14: Testing & Compatibility
        |
        v
Phase 15: Universal Binary & DMG
        |
        v
Phase 16: Final Release
```

Some implementation work can proceed in parallel when its dependencies are satisfied. However, a dependent phase must not be declared complete until its required components are integrated and tested.

---

# 4. Definition of Done

A phase is considered complete only when all of the following conditions are satisfied:

1. All tasks within the phase are implemented.
2. The implementation follows the agreed architecture.
3. The code compiles successfully.
4. Relevant tests have been executed.
5. No known critical defects remain in the phase.
6. The deliverables are present.
7. Completion criteria are verified.
8. `CURRENT_STATUS.md` is updated.

A partially implemented feature must not be marked complete.

If a task is blocked, document the reason and its dependency.

---

# 5. Development Rules

These rules apply throughout the entire project.

### Code Quality

- Use clear and meaningful naming.
- Keep components modular.
- Avoid unnecessary abstractions.
- Avoid duplicated logic.
- Use appropriate Swift access control.
- Handle errors explicitly.
- Use concurrency safely.
- Keep UI and network logic separate.

### Network Monitoring

- Always use actual macOS interface counters.
- Do not use simulated speed values in production.
- Do not blindly sum every network interface.
- Use actual elapsed sampling time.
- Handle counter resets.
- Handle interface changes.
- Do not persist traffic measurements.

### UI/UX

- Keep the menu bar as the primary interface.
- Keep Settings compact.
- Avoid unnecessary windows.
- Avoid dashboards.
- Avoid charts.
- Avoid extra diagnostics.
- Preserve the agreed display modes.
- Use native macOS behavior.

### Scope Control

Do not add:

- Speed tests.
- Network history.
- Traffic reports.
- Public IP lookup.
- Ping monitoring.
- DNS diagnostics.
- Packet loss monitoring.
- Wi-Fi signal monitoring.
- User accounts.
- Cloud synchronization.
- Analytics.
- Advertisements.
- Backend services.

Any scope change must first be reflected in `PROJECT_REQUIREMENTS.md` and `TECHNICAL_ARCHITECTURE.md`.

---

# 6. Final Release Checklist

The following checklist must be completed before declaring ANC production-ready.

### Application

- [ ] Native macOS application.
- [ ] Menu bar-only normal operation.
- [ ] Correct application identity.
- [ ] No unnecessary Dock icon.

### Network Monitoring

- [ ] Actual download speed.
- [ ] Actual upload speed.
- [ ] Correct interface selection.
- [ ] Correct elapsed-time calculation.
- [ ] Network reconnection handling.
- [ ] Interface-change handling.

### Display Modes

- [ ] Both Directions — Separate Speeds.
- [ ] Both Directions — Combined Arrows.
- [ ] Single Direction — Manual Download.
- [ ] Single Direction — Manual Upload.
- [ ] Single Direction — Automatic.
- [ ] Correct idle display.

### Settings

- [ ] All display settings.
- [ ] Preference persistence.
- [ ] Launch at Login.
- [ ] Setup Guide.
- [ ] Usage Guide.
- [ ] Terms and Conditions.
- [ ] Privacy Policy.
- [ ] About ANC.

### Performance & Reliability

- [ ] Low resource consumption.
- [ ] No unnecessary background work.
- [ ] No persistent network history.
- [ ] No unnecessary permissions.
- [ ] Stable long-running operation.
- [ ] Clean application termination.

### Distribution

- [ ] Universal Binary verified.
- [ ] DMG generated.
- [ ] Drag-to-Applications installation verified.
- [ ] Independent launch verified.
- [ ] Signing verified where configured.
- [ ] Notarization verified where configured.
- [ ] Clean Mac installation tested.

---

# 7. Project Completion

ANC development is complete when all 16 phases have been implemented, tested, and verified.

The final deliverable must be:

```text
ARRY-Network-Counter.dmg
```

The user should be able to:

1. Transfer the DMG to another supported Mac.
2. Open the DMG.
3. Drag `ARRY Network Counter.app` into Applications.
4. Launch the application.
5. See real-time network speeds in the menu bar.
6. Configure the preferred display mode.
7. Optionally enable Launch at Login.

No Xcode installation, Swift environment, backend, database, or additional development setup should be required on the destination Mac.

---

**Document:** `IMPLEMENTATION_PHASES.md`  
**Project:** ARRY Network Counter (ANC)  
**Organization:** ARRRY  
**Total Phases:** 16  
**Status:** Ready for Development