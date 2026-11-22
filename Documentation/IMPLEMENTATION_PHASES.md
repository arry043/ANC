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
**Status:** Completed

### Objective

Integrate all three display modes and both sub-options of Both Directions.

### Tasks

**Both Directions — Separate Speeds**

- [x] Display both arrows.
- [x] Display download speed independently.
- [x] Display upload speed independently.
- [x] Apply separate arrow colors.
- [x] Update both values dynamically.

**Both Directions — Combined Arrows**

- [x] Always display both arrows.
- [x] Display only one numerical speed.
- [x] Use the dominant direction engine.
- [x] Switch the numerical speed when dominance changes.
- [x] Display `↓ ↑ 0 KB/s` when idle.

**Single Direction — Manual**

- [x] Implement Download selection.
- [x] Implement Upload selection.
- [x] Display only the selected direction.
- [x] Keep the selected direction until changed.

**Single Direction — Automatic**

- [x] Display only one arrow.
- [x] Use the dominant direction engine.
- [x] Switch between Download and Upload.
- [x] Display `↓ 0 KB/s` when idle.

### Deliverables

- All required display modes (`MenuBarContentBuilder.swift`, `MenuBarContent.swift`, `MenuBarRenderer.swift`).
- Fully integrated rendering logic in `MenuBarManager.swift`.
- Mode transition and integration tests (`MenuBarContentBuilderTests.swift`, `DisplayModeIntegrationTests.swift`).

### Completion Criteria

- [x] Both Directions — Separate works.
- [x] Both Directions — Combined works.
- [x] Single Direction — Manual Download works.
- [x] Single Direction — Manual Upload works.
- [x] Single Direction — Automatic works.
- [x] All modes update using real network measurements.
- [x] Changing modes does not restart network monitoring.
- [x] No incorrect or additional speed values are displayed.

---

## Phase 10 — Settings Interface & Preferences

**Priority:** High  
**Status:** Completed

### Objective

Implement the compact native Settings window and persistent user preferences.

### Tasks

- [x] Implement `SettingsManager`.
- [x] Implement `PreferencesStore`.
- [x] Implement `SettingsView`.
- [x] Implement Display Settings.
- [x] Add Both Directions configuration.
- [x] Add Separate Speeds selection.
- [x] Add Combined Arrows selection.
- [x] Add Single Direction — Manual.
- [x] Add Download selection.
- [x] Add Upload selection.
- [x] Add Single Direction — Automatic.
- [x] Implement Launch at Login toggle.
- [x] Add documentation navigation.
- [x] Persist display preferences using UserDefaults.
- [x] Restore preferences after application relaunch.
- [x] Apply setting changes immediately.

### Preference Keys

```text
displayMode
bothDirectionsStyle
manualDirection
launchAtLogin
```

### Deliverables

- Complete Settings window (`SettingsView.swift`, `SettingsManager.swift`).
- Persistent preferences (`PreferencesStore.swift`).
- Immediate settings updates via `ApplicationCoordinator` and `MenuBarManager`.
- Comprehensive test coverage (`PreferencesStoreTests.swift`, `SettingsBehaviorTests.swift`).

### Completion Criteria

- [x] All display options are accessible.
- [x] Only relevant options are shown for the selected mode.
- [x] Settings are saved correctly.
- [x] Settings persist after relaunch.
- [x] Invalid or missing preferences use safe defaults.
- [x] Display updates immediately after configuration changes.
- [x] Settings remain compact and easy to use.
- [x] Settings window supports responsive resizing with `.resizable` styleMask.
- [x] Horizontal segmented control overflow resolved by native radioGroup selection for multi-word modes.
- [x] Content respects available window width with zero horizontal clipping or off-screen shifting.
- [x] Visual alignment verified across window sizes (460x500 to 800x700), tabs, and appearance modes.
- [x] Both Directions supports Without Arrows presentation (`DL <dlSpeed>    UL <ulSpeed>`).
- [x] Single Direction Manual supports Arrow Visibility toggle (`With Arrow` vs `Without Arrows`).
- [x] Single Direction Automatic supports Arrow Visibility toggle (`With Arrow` vs `Without Arrows`).
- [x] Persistent storage for `singleDirectionArrowStyle` with safe defaults and backward compatibility.

---

## Phase 11 — Application Lifecycle & Launch at Login

**Priority:** High  
**Status:** Completed

### Objective

Complete application lifecycle handling and optional macOS login launch support.

### Tasks

- [x] Implement application startup coordination.
- [x] Start network monitoring on application launch.
- [x] Ensure only one sampling task exists.
- [x] Implement monitoring task cancellation.
- [x] Handle application termination.
- [x] Implement `LoginItemManager`.
- [x] Integrate `ServiceManagement`.
- [x] Use `SMAppService` where supported.
- [x] Implement login launch registration.
- [x] Implement login launch unregistration.
- [x] Reflect registration state in Settings.
- [x] Handle registration errors.
- [x] Ensure the application works without login launch.

### Deliverables

- Stable application lifecycle (`ApplicationCoordinator.swift`, `NetworkPathManager.swift`, `AppDelegate.swift`).
- Optional Launch at Login functionality (`LoginItemManager.swift`, `ServiceManagement`).
- Reliable monitoring startup and shutdown with single-pipeline enforcement.
- Comprehensive test coverage (`ApplicationLifecycleTests.swift`, `LoginItemManagerTests.swift`).

### Completion Criteria

- [x] Monitoring starts automatically on launch.
- [x] Duplicate sampling tasks are prevented.
- [x] Monitoring stops on Quit.
- [x] Login launch can be enabled.
- [x] Login launch can be disabled.
- [x] Registration failures do not crash the application.
- [x] No unnecessary background process remains after termination.

---

## Phase 12 — Documentation & About Section

**Priority:** Medium  
**Status:** Completed

### Objective

Implement offline documentation and application information inside Settings.

### Tasks

- [x] Create Setup Guide.
- [x] Document DMG installation.
- [x] Document copying the app into Applications.
- [x] Document first-launch security approval where applicable.
- [x] Document Settings access.
- [x] Document Launch at Login.
- [x] Create Usage Guide.
- [x] Explain all display modes.
- [x] Explain automatic direction switching.
- [x] Explain supported units.
- [x] Explain measurement limitations.
- [x] Create Terms and Conditions.
- [x] Create Privacy Policy.
- [x] Implement About ANC.
- [x] Display application version.
- [x] Display ARRRY branding.
- [x] Display copyright information.
- [x] Bundle documentation with the application.

### Deliverables

- Complete offline documentation (`SETUP_GUIDE.md`, `USAGE_GUIDE.md`, `TERMS_AND_CONDITIONS.md`, `PRIVACY_POLICY.md`).
- About section inside Settings (`AboutView.swift`).
- Documentation navigation and native markdown reader (`DocumentReaderView.swift`).
- Documentation loader and resource provider (`DocumentationProvider.swift`).
- Comprehensive unit test suite (`DocumentationTests.swift` - 10 assertions).

### Completion Criteria

- [x] All documentation is accessible offline.
- [x] Setup instructions are accurate.
- [x] Display modes are clearly explained.
- [x] Privacy statements match the actual implementation.
- [x] Version and organization information are correct.
- [x] No placeholder documentation remains.

---

## Phase 13 — Error Handling & Performance Optimization

**Priority:** High  
**Status:** Completed

### Objective

Improve stability, resource efficiency, and recovery from unexpected system conditions.

### Tasks

- [x] Review all network error paths.
- [x] Handle interface statistics retrieval failures.
- [x] Handle network disconnections.
- [x] Handle network reconnections.
- [x] Handle interface changes.
- [x] Handle invalid counter snapshots.
- [x] Handle unexpected sampling delays.
- [x] Review task cancellation.
- [x] Review actor isolation.
- [x] Prevent duplicate monitoring tasks.
- [x] Prevent unnecessary menu bar updates.
- [x] Reduce unnecessary allocations.
- [x] Review memory usage.
- [x] Review CPU consumption.
- [x] Verify no traffic history is persisted.
- [x] Verify no external network requests are made by the monitoring implementation.

### Deliverables

- Improved application stability and unified logging (`AppLogger.swift`).
- Optimized monitoring pipeline and interface failure handling (`NetworkPathManager.swift`, `NetworkInterfaceSelector.swift`).
- Timing boundary and counter discontinuity protection (`NetworkSpeedCalculator.swift`).
- Redundant render suppression with change detection (`MenuBarManager.swift`).
- Comprehensive error handling and performance test suite (`ErrorHandlingAndPerformanceTests.swift` - 12 assertions).

### Completion Criteria

- [x] Temporary network errors do not crash the app.
- [x] Monitoring recovers after reconnection.
- [x] No duplicate sampling tasks.
- [x] No unnecessary continuous CPU activity.
- [x] No persistent traffic history.
- [x] No unnecessary external dependencies or requests.
- [x] Application remains stable during extended operation.

---

## Phase 14 — Comprehensive Testing & Compatibility

**Priority:** Critical  
**Status:** Completed

### Objective

Perform complete unit, integration, manual, and compatibility testing.

### Tasks

**Unit Testing**

- [x] Test speed calculations.
- [x] Test counter reset handling.
- [x] Test elapsed-time calculations.
- [x] Test byte formatting.
- [x] Test unit boundaries.
- [x] Test dominant direction selection.
- [x] Test switching hysteresis.
- [x] Test settings persistence.
- [x] Test interface selection.

**Integration Testing**

- [x] Test interface statistics to speed calculation.
- [x] Test speed calculation to formatter.
- [x] Test formatter to menu bar.
- [x] Test all display modes.
- [x] Test network path changes.
- [x] Test Settings updates.
- [x] Test application lifecycle.

**Manual Testing**

- [x] Test Wi-Fi.
- [ ] Test Ethernet where available. *(Not Verified: physical Ethernet hardware not present)*
- [x] Test VPN.
- [x] Test network disconnection.
- [x] Test network reconnection.
- [x] Test switching between interfaces.
- [x] Test Light Mode.
- [x] Test Dark Mode.
- [x] Test long-running sessions.
- [x] Test launch at login.
- [x] Test clean application termination.

**Compatibility Testing**

- [x] Test Apple Silicon build.
- [ ] Test Intel build where hardware is available. *(Not Verified: physical Intel hardware not present; x86_64 slice compiled and verified)*
- [x] Verify minimum macOS version compatibility.
- [x] Verify Universal Binary architecture slices.
- [x] Verify native application behavior after installation.

### Deliverables

- Complete test suite (`Tests/ComprehensiveCompatibilityTests.swift` — 25 suites, 249 assertions).
- Testing report (`Documentation/TESTING_REPORT.md`).
- Verified application behavior.

### Completion Criteria

- [x] All required unit tests pass.
- [x] Integration tests pass.
- [x] All display modes work correctly.
- [x] Network transitions work correctly.
- [x] No known critical or high-severity defects remain.
- [x] Target architecture compatibility is verified.
- [x] Release blockers are resolved.

---

## Phase 15 — Universal Binary & DMG Packaging

**Priority:** Critical  
**Status:** Completed

### Objective

Prepare the production application and create an installable DMG that works on supported Macs without development tools.

### Tasks

- [x] Configure Release build settings.
- [x] Build for `arm64`.
- [x] Build for `x86_64`.
- [x] Create the Universal Binary.
- [x] Verify architecture slices.
- [x] Configure application bundle metadata.
- [x] Configure application version.
- [x] Configure bundle identifier.
- [x] Verify bundled documentation.
- [x] Prepare the Applications shortcut.
- [x] Create the DMG.
- [x] Configure DMG presentation.
- [x] Verify the DMG opens.
- [x] Verify the app can be dragged into Applications.
- [x] Verify the installed app launches independently.
- [x] Confirm Xcode and development tools are not required on the destination Mac.

### Expected Output

```text
dist/
│
├── ARRY Network Counter.app
│
└── ARRY-Network-Counter.dmg
```

### Code Signing & Notarization

- [ ] Configure Developer ID signing when credentials are available. *(Apple Developer certificate absent in keychain)*
- [x] Enable hardened runtime as required.
- [x] Sign the application (ad-hoc signed for personal/developer testing).
- [ ] Submit for Apple notarization. *(Apple Developer account credentials absent)*
- [ ] Staple the notarization ticket. *(Apple Developer account credentials absent)*
- [x] Sign and verify the DMG as appropriate.
- [x] Verify Gatekeeper behavior and document security override instructions.

If signing or notarization credentials are unavailable, document the limitation and produce a clearly identified personal-testing build. Do not claim that an unsigned build is notarized.

### Deliverables

- Universal application bundle (`dist/ARRY Network Counter.app`).
- Installable DMG (`dist/ARRY-Network-Counter.dmg`).
- Build and verification scripts (`Scripts/release.sh`).
- Release verification report (`Documentation/RELEASE_REPORT.md`).

### Completion Criteria

- [x] DMG is generated successfully.
- [x] DMG installation works.
- [x] Application runs from Applications.
- [x] No development environment is required.
- [x] Intended architecture slices are verified.
- [x] Signing and notarization status is accurately documented.

---

## Phase 16 — Final Release & Deployment Verification

**Priority:** Critical  
**Status:** Completed

### Objective

Complete the final release audit and prepare ANC for distribution.

### Tasks

- [x] Perform a clean installation test.
- [x] Test on a Mac without the development environment.
- [x] Verify all display modes.
- [x] Verify network speed accuracy.
- [x] Verify menu bar appearance.
- [x] Verify Settings.
- [x] Verify Launch at Login.
- [x] Verify Quit behavior.
- [x] Verify documentation.
- [x] Verify privacy implementation.
- [x] Verify no backend or database dependencies.
- [x] Verify no unnecessary permissions.
- [x] Verify application version.
- [x] Verify DMG filename.
- [x] Verify code signing and notarization where configured.
- [x] Prepare final release notes.
- [x] Archive the final release artifacts.

### Deliverables

- Release-ready ANC application (`dist/ARRY Network Counter.app`).
- Final DMG installer (`dist/ARRY-Network-Counter.dmg`).
- Release notes (`Documentation/RELEASE_NOTES.md`).
- Final verification report (`Documentation/RELEASE_VERIFICATION_REPORT.md`).
- Release archive with SHA-256 checksums (`release/v1.0.0/`).

### Completion Criteria

- [x] All required functionality is implemented.
- [x] All critical tests pass.
- [x] No known release-blocking defects remain.
- [x] Installation instructions are complete.
- [x] Distribution artifacts are verified.
- [x] Final release status is documented.

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