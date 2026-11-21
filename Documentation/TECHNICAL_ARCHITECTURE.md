# TECHNICAL_ARCHITECTURE.md

# ARRY Network Counter (ANC)

**Organization:** ARRRY  
**Application:** ARRY Network Counter  
**Short Name:** ANC  
**Platform:** macOS  
**Application Type:** Native Menu Bar Utility  
**Architecture:** Native macOS Application  
**Status:** Architecture Defined

---

## 1. Architecture Overview

ARRY Network Counter (ANC) is a lightweight native macOS menu bar application that continuously monitors network interface traffic and displays the current download and upload speeds.

The application follows a simple, local-first architecture.

### Core Architecture

- Native macOS application built with Swift.
- SwiftUI for application settings and documentation windows.
- AppKit for menu bar integration and precise status item rendering.
- Network.framework for network path monitoring.
- macOS network interface statistics for traffic measurement.
- Swift Concurrency for asynchronous monitoring and lifecycle management.
- UserDefaults for essential local preferences.
- Xcode for development, building, signing, and packaging.

### Architecture Principles

1. Native macOS implementation.
2. Minimal memory and CPU consumption.
3. No unnecessary dependencies.
4. No backend or external services.
5. No database or persistent traffic history.
6. Accurate network speed calculations.
7. Clear separation of monitoring, calculation, formatting, and presentation.
8. Universal Binary support for Apple Silicon and Intel Macs.

---

## 2. Technology Stack

| Component | Technology | Responsibility |
|---|---|---|
| Programming Language | Swift 6 | Application implementation |
| UI Framework | SwiftUI | Settings and documentation |
| Menu Bar Integration | AppKit | NSStatusItem and menu bar rendering |
| Network Monitoring | Network.framework | Network path and connectivity changes |
| Network Statistics | getifaddrs / System Interface Counters | Received and transmitted byte counters |
| Concurrency | Swift Concurrency | Background sampling and lifecycle |
| Local Preferences | UserDefaults | Application settings |
| Login Integration | ServiceManagement | Optional launch at login |
| IDE | Xcode | Development and build |
| Distribution | DMG | Application installation |
| Binary Architecture | Universal Binary | arm64 and x86_64 |

### Dependencies

The application should primarily use Apple's native frameworks.

No third-party package should be introduced unless it solves a necessary technical problem that cannot be handled reliably with native APIs.

---

## 3. High-Level System Architecture

```text
                 ARRY NETWORK COUNTER
                         |
                         |
                 Application Entry
                         |
                 Application Manager
                         |
          +--------------+--------------+
          |              |              |
          |              |              |
     Network         Settings       Menu Bar
     Monitoring      Manager         Manager
          |              |              |
          |              |              |
     NWPathMonitor   UserDefaults    NSStatusItem
          |              |              |
          |              |              |
     Interface       Preferences     Display Renderer
     Selection          |              |
          |              |              |
          |              |              |
     Interface       Display Mode    Formatted Speed
     Statistics      Configuration       |
          |              |              |
          +--------------+--------------+
                         |
                  Speed Calculator
                         |
                  Speed Formatter
                         |
                  Dominant Direction
                         |
                  Menu Bar Display
```

### Component Responsibilities

**Application Manager**
- Initializes application services.
- Coordinates application lifecycle.
- Starts and stops monitoring.
- Handles application termination.

**Network Monitoring**
- Detects network connectivity changes.
- Identifies the active network path.
- Coordinates interface selection.
- Retrieves network interface byte counters.

**Settings Manager**
- Loads and saves user preferences.
- Provides the current display configuration.
- Notifies dependent components when settings change.

**Speed Calculator**
- Calculates download and upload speeds.
- Handles counter changes and resets.
- Uses actual elapsed time.
- Produces normalized speed measurements.

**Dominant Direction Engine**
- Determines whether download or upload is dominant.
- Applies switching hysteresis.
- Prevents unnecessary visual switching.

**Speed Formatter**
- Converts bytes per second into readable units.
- Applies appropriate decimal precision.
- Produces formatted menu bar text.

**Menu Bar Manager**
- Creates and manages the macOS status item.
- Updates the displayed speed.
- Handles access to Settings and Quit.

---

## 4. Suggested Project Structure

Use a clean, modular Swift project structure.

```text
ARRY-Network-Counter/
│
├── ARRYNetworkCounter.xcodeproj
│
├── ARRYNetworkCounter/
│   │
│   ├── App/
│   │   ├── ANApp.swift
│   │   ├── AppDelegate.swift
│   │   ├── AppCoordinator.swift
│   │   └── AppLifecycleManager.swift
│   │
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── NetworkSpeed.swift
│   │   │   ├── NetworkSnapshot.swift
│   │   │   ├── NetworkInterface.swift
│   │   │   ├── DisplayMode.swift
│   │   │   └── AppPreferences.swift
│   │   │
│   │   ├── Protocols/
│   │   │   ├── NetworkMonitoringProtocol.swift
│   │   │   └── PreferencesProtocol.swift
│   │   │
│   │   └── Utilities/
│   │       ├── ByteFormatter.swift
│   │       ├── MonotonicClock.swift
│   │       └── NetworkConstants.swift
│   │
│   ├── Network/
│   │   ├── NetworkMonitor.swift
│   │   ├── NetworkPathManager.swift
│   │   ├── NetworkInterfaceProvider.swift
│   │   ├── NetworkInterfaceSelector.swift
│   │   ├── NetworkSampler.swift
│   │   └── NetworkSpeedCalculator.swift
│   │
│   ├── Display/
│   │   ├── MenuBarManager.swift
│   │   ├── MenuBarRenderer.swift
│   │   ├── DominantDirectionEngine.swift
│   │   └── SpeedFormatter.swift
│   │
│   ├── Settings/
│   │   ├── SettingsManager.swift
│   │   ├── SettingsView.swift
│   │   ├── DisplaySettingsView.swift
│   │   ├── GeneralSettingsView.swift
│   │   ├── DocumentationView.swift
│   │   └── AboutView.swift
│   │
│   ├── Services/
│   │   ├── LoginItemManager.swift
│   │   └── PreferencesStore.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Documentation/
│   │   │   ├── SETUP_GUIDE.md
│   │   │   ├── USAGE_GUIDE.md
│   │   │   ├── TERMS_AND_CONDITIONS.md
│   │   │   └── PRIVACY_POLICY.md
│   │   └── Info.plist
│   │
│   └── ARRYNetworkCounterTests/
│       ├── NetworkSpeedCalculatorTests.swift
│       ├── ByteFormatterTests.swift
│       ├── DominantDirectionEngineTests.swift
│       ├── NetworkInterfaceSelectorTests.swift
│       └── SettingsManagerTests.swift
│
├── Documentation/
│   ├── PROJECT_REQUIREMENTS.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── IMPLEMENTATION_PHASES.md
│   └── CURRENT_STATUS.md
│
├── Scripts/
│   ├── build.sh
│   ├── create-dmg.sh
│   └── verify-universal-binary.sh
│
├── .gitignore
└── README.md
```

The structure is a proposed logical organization. It can be adjusted during implementation without changing the defined architecture.

---

## 5. Application Lifecycle

ANC should behave like a lightweight macOS menu bar utility.

### Startup Flow

1. macOS launches ANC.
2. Application initializes its core services.
3. Preferences are loaded from UserDefaults.
4. The menu bar status item is created.
5. Network path monitoring starts.
6. The active network interface is identified.
7. Initial network counters are collected.
8. The sampling process starts.
9. The menu bar displays the current network speed.

### Runtime Flow

While ANC is running:

- Network statistics are sampled continuously.
- Download and upload speeds are calculated.
- The current display mode is applied.
- The menu bar is refreshed approximately once per second.
- Network path changes trigger interface re-evaluation.
- Updated settings are applied without restarting the application.

### Termination Flow

When the user quits ANC:

- The sampling task is cancelled.
- Network path monitoring is stopped.
- Active asynchronous tasks are cancelled.
- The menu bar status item is removed.
- Application resources are released.

No background monitoring should continue after the application has terminated.

---

## 6. Menu Bar Architecture

### AppKit Integration

Use AppKit's `NSStatusItem` to manage the macOS menu bar item.

The menu bar display should be controlled programmatically instead of relying on a large SwiftUI view.

This provides precise control over:

- Display text.
- Download and upload arrows.
- Text spacing.
- Font size.
- Direction-specific colors.
- Dynamic speed updates.
- Menu bar width.

### Display Examples

**Both Directions — Separate Speeds**

```text
↓ 2.45 MB/s    ↑ 120 KB/s
```

**Both Directions — Combined Switching Speed**

```text
↓ ↑ 2.45 MB/s
```

**Single Direction — Manual Download**

```text
↓ 2.45 MB/s
```

**Single Direction — Manual Upload**

```text
↑ 120 KB/s
```

**Single Direction — Automatic**

```text
↓ 2.45 MB/s
```

### Color Configuration

| Element | Color |
|---|---|
| Download Arrow | Green |
| Upload Arrow | Blue |
| Speed Text | System Menu Bar Text Color |
| Background | Transparent / Native Menu Bar |

Use native attributed strings or equivalent AppKit rendering to apply different colors to individual arrows.

The implementation must remain readable in both Light Mode and Dark Mode.

### Menu Interaction

Keep interaction minimal.

The status item should provide access to:

- Settings
- Quit ANC

Do not introduce a dashboard, monitoring popover, charts, or unnecessary menu items.

The Settings window can be opened from the status item's native menu.

---

## 7. Network Monitoring Architecture

This is the most important technical component of ANC.

The application must retrieve actual network traffic counters from macOS rather than estimating speed or generating synthetic measurements.

### 7.1 Network Path Detection

Implemented via `NetworkPathManager` leveraging Apple's `Network.framework` and `NWPathMonitor`.

#### Implementation Architecture

- **Monitor Ownership:** `NetworkPathManager` (actor) owns the `NWPathMonitor` instance and manages its lifecycle.
- **Queue Isolation:** Monitor updates are dispatched onto a dedicated serial utility queue (`in.arrry.networkcounter.pathmonitor`).
- **Domain State Decoupling:** Callback paths are immediately converted into immutable `NetworkPathState` domain models, preventing framework objects from leaking across concurrency domains.
- **Provider Abstraction:** `PathMonitorProviding` protocol enables test injection with `MockPathMonitorProvider`, while production uses `SystemPathMonitorProvider`.
- **Event Propagation:** Exposes `pathStateStream: AsyncStream<NetworkPathState>`, observed by `ApplicationCoordinator` on `@MainActor`.
- **Duplicate Suppression:** Compares consecutive states and drops identical updates to minimize churn.
- **Session Tokens:** Employs generation counters (`currentSessionID`) to ensure callbacks from terminated monitoring sessions cannot overwrite state after restart.

#### Responsibilities:

- Detect whether a usable network path exists (`status == .satisfied`).
- Detect connectivity transitions (`satisfied`, `unsatisfied`, `requiresConnection`).
- Identify available interface types (Wi-Fi, Ethernet, Cellular, Loopback, Other).
- Detect expensive (cellular/hotspot) or constrained (low-data) paths.
- React to network transitions and trigger interface re-evaluation in Phase 04.

`NWPathMonitor` is responsible for network path awareness, not byte-counter measurement. It does not directly provide the received and transmitted byte totals needed for speed calculation.

### 7.2 Interface Statistics

The application retrieves cumulative network counters directly from macOS BSD kernel interfaces via `getifaddrs()`.

The implementation consists of:

- `NetworkInterfaceStatistics`: Strongly typed immutable model encapsulating cumulative `receivedBytes` (`ifi_ibytes`), `transmittedBytes` (`ifi_obytes`), interface name, kernel index, hardware classification, operational flags (`IFF_UP`, `IFF_RUNNING`, `IFF_LOOPBACK`), wall-clock timestamp, and high-resolution monotonic nanosecond timestamps (`DispatchTime.now().uptimeNanoseconds`).
- `NetworkInterfaceProviding`: Protocol contract defining asynchronous interface statistics enumeration for dependency injection and testing.
- `SystemNetworkInterfaceProvider`: Production implementation parsing `AF_LINK` records and casting `ifa_data` to `struct if_data`.
- `MockNetworkInterfaceProvider`: Thread-safe actor-isolated mock provider for deterministic unit testing.

Memory safety guarantee:
```swift
var ifap: UnsafeMutablePointer<ifaddrs>? = nil
let status = getifaddrs(&ifap)
guard status == 0, let first = ifap else {
    throw NetworkInterfaceProviderError.enumerationFailed(errno: errno)
}
defer {
    freeifaddrs(first)
}
```

The `freeifaddrs()` call is guaranteed to execute unconditionally via Swift's `defer` statement on every execution and error exit path.

### 7.3 Interface Selection

The application enforces a strict single-interface selection policy to completely eliminate traffic double-counting:

1. **Zero Double-Counting Rule:** ANC never sums or aggregates multiple interfaces. Blindly aggregating physical (`en0`) and tunnel (`utun0`) interfaces would double-count all routed traffic.
2. **Loopback Exclusion:** Device `lo0` is strictly excluded from active throughput measurement.
3. **Operational State Validation:** Only interfaces with both `IFF_UP` and `IFF_RUNNING` set are considered usable.
4. **Network Path Correlation:** The selector correlates candidate interfaces against the active `NetworkPathState`.

### 7.4 Interface Selection Strategy

`NetworkInterfaceSelector` executes a deterministic multi-stage selection algorithm:

1. **Path Connectivity Check:** If `pathState.status != .satisfied`, returns `.noActivePath`.
2. **Usable Interface Filtering:** Filters out loopback and non-operational interfaces. If none remain, returns `.noUsableInterfaces`.
3. **Active Path Interface Match:** Matches `pathState.activeInterfaceName` directly against usable interfaces (`reason: .activePathInterface`).
4. **Active Path Type Match:** If interface name is absent, matches `pathState.activeInterfaceType` against usable non-virtual interfaces (`reason: .activeInterfaceTypeMatch`).
5. **Deterministic Usable Fallback:** Prioritizes physical interfaces by type (`Ethernet > Wi-Fi > Cellular > Other`) and name (`reason: .primaryUsableFallback`).

The result is expressed via an explicit `SelectionResult`:
- `.selected(NetworkInterfaceStatistics, reason: SelectionReason)`
- `.noActivePath`
- `.noMatchingInterface(requestedName: String?)`
- `.noUsableInterfaces`

```text
Wi-Fi → Ethernet
Ethernet → Wi-Fi
Wi-Fi → VPN
VPN → Wi-Fi
Connected → Disconnected
Disconnected → Connected
```

### Important Measurement Boundary

ANC measures traffic using the selected system network interface's byte counters.

It is not an internet-only traffic analyzer.

Depending on the selected interface and macOS networking configuration, the counters can include local network traffic, VPN traffic, and other traffic visible at that interface.

The application should document this measurement boundary rather than claim that every displayed byte represents internet traffic.

---

## 8. Network Speed Calculation

The speed calculation engine is implemented by `NetworkSpeedCalculator` (`ARRYNetworkCounter/Services/Monitoring/NetworkSpeedCalculator.swift`).

### 8.1 Calculation Engine Architecture

`NetworkSpeedCalculator` is a Swift actor that isolates calculation state, consumes consecutive `NetworkSnapshot` instances, and produces immutable `SpeedCalculationResult` values.

Key structures:
- `SpeedMeasurement`: Holds calculated `download: NetworkSpeed`, `upload: NetworkSpeed`, `elapsedSeconds: Double`, `monotonicTimeNanoseconds: UInt64`, and `interface: NetworkInterface?`.
- `SpeedCalculationResult`:
  - `.calculated(SpeedMeasurement)`
  - `.baselineEstablished`
  - `.baselineReset(reason: BaselineResetReason)` (`interfaceChanged`, `counterDecreased`, `disconnected`, `manualReset`)
  - `.sampleRejected(reason: SampleRejectionReason)` (`zeroElapsedNanoseconds`, `reversedTimestamp`, `nonFiniteElapsedSeconds`)
  - `.noActivePath`

### 8.2 Calculation Formulas

Speed calculations are performed strictly from counter deltas and monotonic elapsed time:

$$\text{Elapsed Seconds} = \frac{\text{Current Monotonic Nanos} - \text{Previous Monotonic Nanos}}{1\,000\,000\,000}$$

$$\text{Download Speed} = \frac{\text{Current Received Bytes} - \text{Previous Received Bytes}}{\text{Elapsed Seconds}}$$

$$\text{Upload Speed} = \frac{\text{Current Transmitted Bytes} - \text{Previous Transmitted Bytes}}{\text{Elapsed Seconds}}$$

Calculated speeds are stored directly in `NetworkSpeed` in bytes per second (B/s). Download and upload calculations are independent.

### 8.3 Monotonic Clock & Timing Safety

To prevent timing artifacts from system clock synchronization, daylight saving shifts, or NTP adjustments:
- Samples use continuous monotonic timestamps (`DispatchTime.now().uptimeNanoseconds`).
- If elapsed nanoseconds $\le 0$, the sample is rejected (`.zeroElapsedNanoseconds` or `.reversedTimestamp`) and the existing baseline is preserved.
- Elapsed time is validated to be strictly positive and finite before division.

### 8.4 Counter Decrease and Discontinuity Handling

When a counter decreases (`current.receivedBytes < previous.receivedBytes` or `current.transmittedBytes < previous.transmittedBytes`):
1. Underflow is prevented by detecting the condition before subtraction.
2. The current snapshot becomes the new baseline.
3. The calculator returns `.baselineReset(reason: .counterDecreased)`.
4. No speed is emitted for that interval, preventing artificial multi-gigabyte speed spikes (see ADR-033).
5. Normal calculation resumes on the subsequent sample.

### 8.5 Interface Transition Handling

Before computing deltas, the calculator validates interface continuity via `haveSameInterfaceIdentity(previous:, current:)`:
- Compares interface name (and index, if present).
- If the interface changes (e.g. `en0` to `en1`, or interface disappears), the baseline is reset with `.baselineReset(reason: .interfaceChanged)`.
- No speed spike is produced across different interfaces.

### 8.6 Lifecycle and Disconnection Management

- **First Sample:** Establishes the initial baseline and returns `.baselineEstablished`. No speed is calculated.
- **Disconnection:** When `NetworkPathState.status != .satisfied`, the coordinator calls `speedCalculator.reset()`, clearing the baseline and publishing `.noActivePath`.
- **Reconnection:** The first snapshot following reconnection establishes a fresh baseline.
- **Stop Monitoring:** Halts active tasks, resets the calculator baseline, and clears published state.

---

## 9. Sampling and Refresh Strategy

The monitoring engine should be lightweight and predictable.

### Recommended Timing

| Operation | Target |
|---|---|
| Network Statistics Sampling | Approximately 1 second |
| Menu Bar Rendering | Approximately 1 second |
| Path Change Detection | Event-driven |
| Settings Updates | Immediate |
| Direction Switching | Responsive to valid samples |

The internal sampling and presentation intervals should be independent.

This allows the monitoring engine to collect samples at a suitable frequency while keeping menu bar updates controlled.

### Sampling Rules

- Use a cancellable asynchronous task.
- Avoid creating a new unmanaged timer on every update.
- Use actual elapsed time for calculations.
- Avoid unnecessary allocations.
- Do not write network samples to disk.
- Avoid excessive UI updates.
- Cancel sampling when the application terminates.

If a faster internal sampling interval is needed for responsive direction switching, it should be configurable internally without exposing unnecessary settings to the user.

---

## 10. Dominant Direction Engine

Both Automatic mode and Combined Arrows mode require a common direction-selection engine.

### 10.1 Dominant Direction

The dominant direction is determined by comparing the current download and upload speeds.

```text
If Download Speed > Upload Speed:
    Dominant Direction = Download

If Upload Speed > Download Speed:
    Dominant Direction = Upload
```

However, directly switching on every tiny difference can cause visual flickering.

Therefore, ANC should implement switching hysteresis.

### 10.2 Switching Hysteresis

Recommended initial behavior:

- The new direction should exceed the current direction by approximately 10%.
- The difference should also exceed a small absolute noise threshold.
- Require confirmation across two consecutive valid samples.
- Keep the existing direction while speeds are close.
- Use Download as the default direction when both directions are idle.

These values should be centralized in the direction engine so they can be tuned during testing.

The purpose is to prevent rapid switching when download and upload speeds are nearly equal.

The switching algorithm must remain responsive and should not introduce unnecessary multi-second delays.

### 10.3 Combined Arrows Mode

Both arrows remain visible.

Only the numerical speed changes according to the dominant direction.

Example:

```text
Download: 2.45 MB/s
Upload:   120 KB/s

Display:
↓ ↑ 2.45 MB/s
```

When upload becomes dominant:

```text
Download: 100 KB/s
Upload:   1.80 MB/s

Display:
↓ ↑ 1.80 MB/s
```

When both directions are idle:

```text
↓ ↑ 0 KB/s
```

### 10.4 Single Direction Automatic Mode

Only the dominant direction is displayed.

Example:

```text
Download Dominant:
↓ 2.45 MB/s

Upload Dominant:
↑ 1.80 MB/s

Idle:
↓ 0 KB/s
```

### 10.5 Single Direction Manual Mode

The dominant direction engine is not used to determine the displayed direction.

The user's saved preference controls the output.

```text
Selected Direction = Download
Display = Download Speed

Selected Direction = Upload
Display = Upload Speed
```

---

## 11. Speed Formatting Architecture

The formatting engine converts raw network speeds into human-readable strings for menu-bar presentation. It is implemented by two stateless value types:

- `ByteFormatter` (`ARRYNetworkCounter/Services/Formatting/ByteFormatter.swift`): Handles base-1000 unit scaling, boundary evaluation, decimal formatting, trailing-zero stripping, and returns structured `FormattedByteSpeed` models.
- `SpeedFormatter` (`ARRYNetworkCounter/Services/Formatting/SpeedFormatter.swift`): High-level façade consuming domain `NetworkSpeed` models and delegating conversion to `ByteFormatter`.

### 11.1 Supported Units

ANC adheres strictly to decimal byte-based units using SI base-1000 scaling per ADR-014:

| Unit | Conversion Scale | Multiplier |
|---|---:|---:|
| `B/s` | 1 Byte/s | $10^0$ |
| `KB/s` | 1,000 Bytes/s | $10^3$ |
| `MB/s` | 1,000,000 Bytes/s | $10^6$ |
| `GB/s` | 1,000,000,000 Bytes/s | $10^9$ |
| `TB/s` | 1,000,000,000,000 Bytes/s | $10^{12}$ |

Bits per second (`bps`, `Mbps`) and binary IEC prefixes (`KiB/s`, `MiB/s`) are not used.

### 11.2 Automatic Unit Selection

The unit is selected based on the magnitude of the original raw speed value:

$$\text{Unit} = \begin{cases} 
\text{KB/s} & \text{if } \text{speed} = 0 \text{ or non-finite} \\
\text{B/s} & \text{if } 0 < \text{speed} < 1\,000 \\
\text{KB/s} & \text{if } 1\,000 \le \text{speed} < 1\,000\,000 \\
\text{MB/s} & \text{if } 1\,000\,000 \le \text{speed} < 1\,000\,000\,000 \\
\text{GB/s} & \text{if } 1\,000\,000\,000 \le \text{speed} < 1\,000\,000\,000\,000 \\
\text{TB/s} & \text{if } \text{speed} \ge 1\,000\,000\,000\,000
\end{cases}$$

Values above $10^{12}$ B/s continue in `TB/s` (e.g. `10 TB/s`).

### 11.3 Decimal Precision & Trailing Zero Removal

- **`B/s`:** Formatted as an integer (`%.0f`). Positive fractional values below 1 B/s clamp to at least `1 B/s` to distinguish positive activity from zero.
- **`KB/s`, `MB/s`, `GB/s`, `TB/s`:** Formatted with up to 2 decimal places (`%.2f`).
- **Trailing Zero Removal:** Any trailing zeros after the decimal point are removed (`1.50` $\to$ `1.5`, `1.00` $\to$ `1`). If all fractional digits are removed, the decimal point is also stripped (`1.` $\to$ `1`).
- **Locale Independence:** Formatting uses `Locale(identifier: "en_US_POSIX")` ensuring the decimal separator is always a period (`.`) regardless of system locale. No thousands separators or commas are emitted.

### 11.4 Zero-Speed Requirement

Zero network throughput is explicitly formatted as:
```text
0 KB/s
```
This is a product requirement across all display modes. Negative or non-finite inputs (`NaN`, `±Infinity`) safely fall back to `0 KB/s`.

### 11.5 Unit Boundary Rounding Policy (ADR-034)

Unit selection is determined using the raw unrounded speed before decimal rounding. For values immediately below a unit boundary (such as `999,999 B/s`), rounding the scaled KB/s value ($999.999 \to 1000$) produces `1000 KB/s`. When the raw speed reaches $1,000,000 \text{ B/s}$, it transitions cleanly to `1 MB/s`.

---

## 12. Display Mode Architecture

Represent the display configuration using strongly typed Swift enums.

### Proposed Display Modes

```swift
enum DisplayMode {
    case bothDirections
    case singleDirectionManual
    case singleDirectionAutomatic
}

enum BothDirectionsStyle {
    case separateSpeeds
    case combinedArrows
}

enum NetworkDirection {
    case download
    case upload
}
```

These models represent the conceptual configuration. The final implementation should use appropriate `Codable` or raw-value representations for persistence.

### Rendering Logic

```text
Display Mode
    |
    +-- Both Directions
    |       |
    |       +-- Separate Speeds
    |       |       |
    |       |       +-- Show Download + Upload
    |       |
    |       +-- Combined Arrows
    |               |
    |               +-- Show Both Arrows
    |               +-- Show Dominant Speed
    |
    +-- Single Direction Manual
    |       |
    |       +-- Download Selected
    |       |       +-- Show Download
    |       |
    |       +-- Upload Selected
    |               +-- Show Upload
    |
    +-- Single Direction Automatic
            |
            +-- Show Dominant Direction
```

The rendering layer should not calculate network speeds itself.

It should receive already calculated and formatted measurements.

---

## 13. Settings Architecture

Use SwiftUI for the Settings window.

The settings interface should remain compact and focused.

### 13.1 Display Settings

**Both Directions**

- Separate Speeds
- Combined Arrows with Switching Speed

**Single Direction — Manual**

- Download
- Upload

**Single Direction — Automatic**

### 13.2 General Settings

- Launch at Login: Enabled / Disabled.
- Unit selection: Automatic and fixed.
- Refresh interval: Approximately one second and fixed.

Do not expose advanced configuration without a genuine user need.

### 13.3 Documentation

Provide native documentation views for:

- Setup Guide.
- Usage Guide.
- Terms and Conditions.
- Privacy Policy.
- About ANC.

Documentation should be bundled with the application and available offline.

### 13.4 Settings Persistence

Use `UserDefaults`.

Suggested preference keys:

| Key | Type | Purpose |
|---|---|---|
| `displayMode` | String | Selected display mode |
| `bothDirectionsStyle` | String | Separate or combined |
| `manualDirection` | String | Download or upload |
| `launchAtLogin` | Bool | Login launch preference |

Use sensible defaults for a fresh installation.

Do not persist network speed samples or traffic counters.

---

## 14. Launch at Login

Use Apple's `ServiceManagement` framework and `SMAppService` where supported by the selected deployment target.

The feature should:

- Be optional.
- Be disabled by default.
- Reflect the actual registration status where possible.
- Allow users to enable or disable login launch.
- Handle registration failures gracefully.
- Respect macOS login item and user consent behavior.

The application must continue working normally when Launch at Login is disabled.

---

## 15. macOS Application Configuration

### Menu Bar Only Application

ANC should not display a normal Dock icon during regular operation.

Use the appropriate macOS accessory application configuration, such as:

```text
LSUIElement = YES
```

or an equivalent supported application activation policy.

The Settings window must remain accessible even though the application does not appear as a conventional Dock application.

### Permissions

Basic network interface statistics should not require administrator privileges.

The application should not request:

- Full Disk Access.
- Accessibility permissions.
- Screen Recording.
- Location Services.
- Contacts.
- Microphone.
- Camera.

Do not introduce unnecessary permission requests.

### Sandboxing

Evaluate App Sandbox requirements against the chosen network statistics implementation and distribution method.

Do not claim sandbox compatibility until the required system APIs have been tested under the final sandbox configuration.

Prefer the least privileged configuration that supports the application reliably and complies with Apple's distribution requirements.

---

## 16. Concurrency Architecture

Use Swift Concurrency to separate monitoring work from UI presentation.

### Suggested Responsibilities

**Network Sampling**

- Runs asynchronously.
- Retrieves interface statistics.
- Calculates elapsed time.
- Produces network snapshots.

**Network Monitoring**

- Receives path changes.
- Updates interface selection.
- Invalidates stale baselines when needed.

**UI Presentation**

- Runs on the main actor.
- Updates `NSStatusItem`.
- Refreshes Settings state when required.

### Concurrency Rules

1. UI updates must occur on `MainActor`.
2. Network sampling must not block the main thread.
3. Monitoring tasks must be cancellable.
4. Avoid creating duplicate sampling tasks.
5. Avoid shared mutable state without synchronization.
6. Use actors or other appropriate isolation for shared monitoring state.
7. Handle application termination safely.
8. Keep network counter retrieval and UI rendering separate.

---

## 17. Error Handling

ANC should handle system-level failures without crashing.

| Situation | Expected Behavior |
|---|---|
| No Network Connection | Display zero speed |
| Network Interface Missing | Re-evaluate interface selection |
| Interface Changes | Reset baseline and resume |
| Counter Decreases | Establish new baseline |
| Counter Retrieval Fails | Preserve app stability and retry |
| Invalid Sampling Interval | Reject the sample |
| Settings Load Failure | Use safe defaults |
| Login Registration Failure | Keep application usable |
| Network Path Changes | Refresh selected interface |

Avoid unnecessary error dialogs for temporary network conditions.

A lightweight utility should recover automatically whenever possible.

---

## 18. Performance and Resource Management

ANC should remain lightweight while running for extended periods.

### Performance Requirements

- No continuous CPU-intensive operations.
- No unnecessary polling faster than required.
- No network speed test requests.
- No background database operations.
- No historical traffic aggregation.
- No unnecessary UI redraws.
- No unnecessary memory allocations.
- No persistent network statistics.

### Memory Management

Only retain the information required for current calculations:

- Previous network counters.
- Previous sample timestamp.
- Current download speed.
- Current upload speed.
- Selected interface information.
- Current direction-selection state.

Historical measurements should be discarded after they are no longer needed.

---

## 19. Testing Architecture

Testing should focus on correctness, reliability, and long-running behavior.

### Unit Tests

**NetworkSpeedCalculatorTests**
- Download speed calculation.
- Upload speed calculation.
- Different elapsed intervals.
- First sample handling.
- Counter reset handling.
- Invalid counter handling.

**ByteFormatterTests**
- KB/s formatting.
- MB/s formatting.
- GB/s formatting.
- TB/s formatting.
- Zero speed.
- Decimal precision.
- Unit boundary transitions.

**DominantDirectionEngineTests**
- Download dominant.
- Upload dominant.
- Equal speeds.
- Hysteresis.
- Consecutive sample confirmation.
- Idle default direction.
- Rapid direction changes.

**NetworkInterfaceSelectorTests**
- Preferred interface selection.
- Loopback exclusion.
- Interface changes.
- Missing interface.
- Virtual interface handling.

**SettingsManagerTests**
- Default settings.
- Preference persistence.
- Preference restoration.
- Invalid stored values.
- Settings changes.

### Integration Tests

Test the complete monitoring pipeline:

```text
Interface Statistics
        |
        v
Network Snapshot
        |
        v
Speed Calculator
        |
        v
Dominant Direction Engine
        |
        v
Speed Formatter
        |
        v
Menu Bar Renderer
```

### Manual Testing

Test on:

- Apple Silicon Mac.
- Intel Mac, if available.
- Wi-Fi connection.
- Ethernet connection.
- VPN connection.
- Network disconnection.
- Network reconnection.
- Light Mode.
- Dark Mode.
- Long-running application sessions.
- Login launch behavior.

---

## 20. Build and Distribution Architecture

### 20.1 Build Configuration

Use Xcode to build the native macOS application.

Recommended binary architectures:

```text
arm64
x86_64
```

Build a Universal Binary where supported by the chosen macOS deployment target and all linked dependencies.

### 20.2 Minimum macOS Version

Choose the deployment target during initial Xcode project configuration.

The target must support:

- SwiftUI Settings interfaces.
- AppKit status items.
- Network.framework.
- Required concurrency APIs.
- ServiceManagement APIs used by the application.

Prefer a reasonably broad macOS compatibility range without adding unnecessary compatibility code.

Verify the selected minimum version against the actual APIs and compiler configuration before finalizing the release.

### 20.3 Application Bundle

Expected output:

```text
ARRY Network Counter.app
```

The application bundle should contain:

- Executable.
- Application resources.
- Documentation.
- Asset catalog.
- Application metadata.

The target Mac must not need Xcode, Swift, or any development environment.

### 20.4 DMG Packaging

Expected installer:

```text
ARRY-Network-Counter.dmg
```

The DMG should contain:

```text
ARRY-Network-Counter.dmg
│
├── ARRY Network Counter.app
│
└── Applications Shortcut
```

Installation process:

1. Open the DMG.
2. Drag `ARRY Network Counter.app` into Applications.
3. Eject the DMG.
4. Launch ANC from Applications.

### 20.5 Code Signing and Notarization

For a polished distribution experience:

- Sign the application using a Developer ID Application certificate.
- Enable hardened runtime where required.
- Sign the application bundle correctly.
- Submit the application for Apple notarization.
- Staple the notarization ticket.
- Sign and verify the final DMG as appropriate.

A paid Apple Developer Program membership is generally required for Developer ID distribution and notarization.

Without signing and notarization credentials, a personal-use DMG can still be produced, but Gatekeeper may display additional security warnings or require manual approval.

### 20.6 Distribution Validation

Before releasing a DMG:

- Verify the application launches on a clean Mac.
- Verify the DMG opens correctly.
- Verify the app can be copied to Applications.
- Verify no development tools are required.
- Verify the binary contains both intended architectures.
- Verify code signing.
- Verify notarization when configured.
- Verify network monitoring works after installation.
- Verify Settings and Quit functionality.

---

## 21. Security and Privacy Architecture

ANC follows a local-first architecture.

### No Backend

The application does not require:

- API servers.
- Cloud infrastructure.
- Remote databases.
- Authentication services.
- External monitoring services.

### No Tracking

The application must not include:

- Analytics.
- Advertising SDKs.
- Tracking pixels.
- Telemetry.
- User behavior tracking.
- Third-party monitoring services.

### Local Data

Only essential preferences are persisted locally.

Network speed measurements and interface counter snapshots remain in memory and are discarded when no longer required.

### Network Access

ANC reads local system network interface statistics.

It does not need to send network traffic to an external server to calculate the displayed speed.

The implementation must not introduce external requests as part of normal monitoring.

---

## 22. Architectural Constraints

The following restrictions must remain intact throughout development.

| Area | Constraint |
|---|---|
| Platform | Native macOS only |
| Language | Swift |
| UI | SwiftUI + AppKit |
| Network Data | macOS interface counters |
| Network Path | Network.framework |
| Storage | UserDefaults only for preferences |
| Backend | Not permitted |
| Database | Not permitted |
| Cloud Services | Not permitted |
| Analytics | Not permitted |
| Advertisements | Not permitted |
| Accounts | Not permitted |
| Traffic History | Not permitted |
| Speed Tests | Not permitted |
| Dashboard | Not permitted |
| Charts | Not permitted |
| Extra Diagnostics | Not permitted |
| Distribution | DMG |
| Architecture | Universal Binary target |

Any proposed feature or dependency that violates these constraints must be rejected unless the project requirements are explicitly changed.

---

## 23. Final Architecture Decision

ARRY Network Counter will use a native Swift-based macOS menu bar architecture.

The application will combine:

- SwiftUI for compact settings and documentation.
- AppKit for menu bar rendering.
- Network.framework for network path awareness.
- macOS interface byte counters for actual traffic measurements.
- Swift Concurrency for asynchronous sampling.
- A dedicated speed calculator and formatter.
- A shared dominant-direction engine for automatic display modes.
- UserDefaults for essential preferences.
- ServiceManagement for optional login launch.
- Xcode for Universal Binary builds.
- DMG packaging for installation on other Macs.

The architecture intentionally avoids databases, backend services, cloud dependencies, telemetry, and unnecessary functionality.

**Final objective:** A small, reliable, native macOS utility that displays real-time download and upload speeds directly in the menu bar with minimal resource usage and a simple user experience.

---

**Document:** `TECHNICAL_ARCHITECTURE.md`  
**Project:** ARRY Network Counter (ANC)  
**Organization:** ARRRY  
**Status:** Architecture Defined