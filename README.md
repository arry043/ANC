# ARRY Network Counter (ANC)

A lightweight native macOS menu bar utility designed to display real-time network download and upload speeds with configurable display modes and zero unnecessary overhead.

**Organization:** ARRRY  
**Platform:** macOS (macOS 13.0+)  
**Technology Stack:** Swift 6, SwiftUI, AppKit  
**Architecture:** Universal Binary (`arm64`, `x86_64`)  
**Current Development Phase:** Phase 16 — Final Release & Deployment Verification (Completed)  
**Status:** v1.0.0 Release Ready (100% Complete)

---

## Overview

ARRY Network Counter (ANC) operates quietly in the macOS menu bar, providing immediate visibility into active network throughput without requiring users to open a dashboard or monitoring window. ANC adheres to strict local-first and privacy-focused principles: it performs calculations locally, requires no cloud backends, stores no historical network logs, and includes no analytics or telemetry.

---

## Technical Stack & Architecture

- **Language:** Swift 6
- **UI Framework:** SwiftUI (Settings and documentation)
- **Menu Bar Integration:** AppKit (`NSStatusItem` programmatic rendering)
- **Network Path Monitoring:** `Network.framework` (`NWPathMonitor`)
- **Traffic Counters:** Native BSD system interface statistics (`getifaddrs`, `if_data`)
- **Concurrency:** Modern Swift Concurrency (`async`/`await`, Actors, `@MainActor`)
- **Preferences:** `UserDefaults`
- **Application Bundle Type:** macOS Menu Bar Utility (`LSUIElement = true`)
- **Binary Target:** Universal Binary (`arm64` Apple Silicon + `x86_64` Intel)

---

## Project Structure

```text
ARRY-Network-Counter/
├── ARRYNetworkCounter.xcodeproj/
├── ARRYNetworkCounter/
│   ├── App/
│   │   ├── ARRYNetworkCounterApp.swift
│   │   └── AppDelegate.swift
│   ├── Core/
│   │   ├── Models/
│   │   ├── Protocols/
│   │   ├── Utilities/
│   │   └── Extensions/
│   ├── Services/
│   │   ├── Network/
│   │   ├── Monitoring/
│   │   └── Preferences/
│   ├── MenuBar/
│   ├── Settings/
│   ├── Resources/
│   │   └── Assets.xcassets/
│   └── Info.plist
├── Documentation/
│   ├── PROJECT_REQUIREMENTS.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── IMPLEMENTATION_PHASES.md
│   ├── CURRENT_STATUS.md
│   ├── PROJECT_DECISIONS.md
│   ├── UserGuides/
│   │   ├── SETUP_GUIDE.md
│   │   └── USAGE_GUIDE.md
│   └── Legal/
│       ├── TERMS_AND_CONDITIONS.md
│       └── PRIVACY_POLICY.md
├── Scripts/
│   └── build.sh
├── Tests/
├── .gitignore
├── project.yml
└── README.md
```

---

## Prerequisites

- macOS 13.0 (Ventura) or later.
- Swift 6.0+ toolchain (Xcode 16+ or macOS Command Line Tools with Swift 6).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (optional, if modifying `project.yml` project specifications).

---

## Opening the Project in Xcode

Open the project directly in Xcode:

```bash
open ARRYNetworkCounter.xcodeproj
```

Select the `ARRYNetworkCounter` scheme and target **My Mac**.

---

## Building and Running

### Using the Build Script (Command Line)

To build a Universal Binary (`arm64` and `x86_64`) application bundle for Debug:

```bash
./Scripts/build.sh Debug
```

To build a Release application bundle:

```bash
./Scripts/build.sh Release
```

The resulting application bundle will be created at:
- `build/Debug/ARRY Network Counter.app`
- `build/Release/ARRY Network Counter.app`

### Running Unit Tests

To execute the unit test suite covering all core models, protocol mocks, and application coordinator:

```bash
./Scripts/test.sh
```

### Running the Application

Launch the built application:

```bash
open "build/Debug/ARRY Network Counter.app"
```

Because `LSUIElement` is set to `true`, the application runs as a menu bar utility without appearing in the Dock.

---

## Documentation

Full project specifications and technical documentation are maintained in the [`Documentation/`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation) directory:

1. [`PROJECT_REQUIREMENTS.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/PROJECT_REQUIREMENTS.md) — Product requirements, display modes, and feature boundaries.
2. [`TECHNICAL_ARCHITECTURE.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/TECHNICAL_ARCHITECTURE.md) — Architectural design, sampling pipeline, and system integration.
3. [`IMPLEMENTATION_PHASES.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/IMPLEMENTATION_PHASES.md) — 16-phase sequential development roadmap and verification criteria.
4. [`CURRENT_STATUS.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/CURRENT_STATUS.md) — Live progress tracker, audit results, and active development phase.
5. [`PROJECT_DECISIONS.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/PROJECT_DECISIONS.md) — Architectural Decision Records (ADRs).

---

## Release & Installation

The production application and installable DMG are packaged in `dist/` and archived in `release/v1.0.0/`:

- **DMG Package:** `dist/ARRY-Network-Counter.dmg` (5.0 MB)
- **Universal Application Bundle:** `dist/ARRY Network Counter.app` (`arm64` + `x86_64`)
- **Release Automation:** Run `./Scripts/release.sh` to execute the full test suite, build both architecture slices, package the bundle, generate the DMG, and perform installation verification.
- **Release Archive:** Checksummed release artifacts with `SHA256SUMS.txt` are maintained in `release/v1.0.0/`.
- **Release Documentation:** See [`RELEASE_NOTES.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/RELEASE_NOTES.md) and [`RELEASE_VERIFICATION_REPORT.md`](file:///Users/arry03/Desktop/ARRRY/ANC/Documentation/RELEASE_VERIFICATION_REPORT.md).
