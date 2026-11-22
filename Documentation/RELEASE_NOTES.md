# ARRY Network Counter (ANC) — Release Notes

**Product:** ARRY Network Counter (ANC)  
**Version:** `1.0.0` (Build `1`)  
**Release Date:** 2026-11-22  
**Bundle Identifier:** `in.arrry.networkcounter`  
**Minimum macOS:** 13.0+ (macOS Ventura, Sonoma, Sequoia)  
**Supported Architectures:** Universal Binary (`arm64` Apple Silicon + `x86_64` Intel)  
**Package:** `ARRY-Network-Counter.dmg`  
**Status:** **v1.0.0 General Release (Personal Testing Ready; Public Gatekeeper Distribution Pending Developer ID Credentials)**

---

## 1. Product Overview

**ARRY Network Counter (ANC)** is a lightweight, local-first macOS menu bar utility designed to monitor and display real-time network download and upload speeds directly in the macOS menu bar. 

Built with Swift 6, SwiftUI, and AppKit, ANC delivers accurate throughput measurements with zero background bloat, zero remote network calls, and an average steady-state CPU footprint of under **0.4%**.

---

## 2. Core Features

### 2.1 Four Native Menu Bar Display Modes

1. **Both Directions — Separate Speeds**:
   - Displays independent download and upload speeds simultaneously: `↓ 1.45 MB/s    ↑ 240 KB/s`.
   - Distinct green download arrow (`↓`) and blue upload arrow (`↑`) with tabular monospaced numbers.
2. **Both Directions — Combined Arrows with Switching Speed**:
   - Shows dual arrows with the single active dominant throughput rate: `↓ ↑ 1.45 MB/s`.
   - Automatically switches displayed rate when dominant direction changes, protected by hysteresis.
3. **Single Direction — Manual**:
   - Pins menu bar display strictly to user-chosen direction: `↓ <download>` or `↑ <upload>`, ignoring opposing traffic.
4. **Single Direction — Automatic**:
   - Displays a single directional arrow dynamically matching dominant traffic (`↓ <dl>` or `↑ <ul>`).
   - Automatically defaults to `↓ 0 KB/s` during idle network state.

### 2.2 3-Factor Direction Switching Hysteresis

To eliminate rapid, distracting visual flickering in the menu bar during balanced traffic, ANC enforces a deterministic 3-factor hysteresis engine:
- **10% Relative Margin**: Opposite traffic rate must exceed active speed by at least 10%.
- **10 KB/s Noise Floor**: Absolute rate difference must exceed 10,000 B/s.
- **2 Consecutive Samples**: Qualifying conditions must persist across 2 consecutive 1-second sample intervals.
- **Flapping Protection**: Isolated spikes followed by recovery to active dominance immediately discard pending candidate states.

### 2.3 Precision Byte & Speed Formatting

- **Base-1000 SI Decimal Scaling**: Follows standard macOS system unit conventions ($1\text{ KB/s} = 1,000\text{ B/s}$, $1\text{ MB/s} = 1,000,000\text{ B/s}$, etc.).
- **Byte-Based Metrics**: Directly reflects Byte throughput ($8\text{ bits} = 1\text{ Byte}$).
- **Clean Numeric Presentation**: Formatted to up to 2 decimal places with trailing zero trimming (e.g. `1.5 MB/s` instead of `1.50 MB/s`). Zero throughput is presented as `0 KB/s`.

### 2.4 Native Settings & Offline Documentation

- **Minimal Native Window**: Clean SwiftUI settings interface accessible from the menu bar status item.
- **Settings Tabs**: Seamless navigation between `Preferences`, `Documentation`, and `About`.
- **Bundled Offline Guides**: Built-in markdown documentation viewer for Setup Guide, Usage Guide, Terms & Conditions, and Privacy Policy—fully accessible without internet connectivity.
- **Optional Launch at Login**: Native macOS `SMAppService` integration allowing the application to launch automatically on login.

---

## 3. Privacy & Security Guarantees

- **100% Local-First**: Zero external network connections, zero telemetry, zero analytics SDKs, and zero crash reporters.
- **Zero Traffic History**: All bandwidth measurements are volatile and calculated in-memory; no network activity, IP addresses, or packet data are recorded or stored.
- **Minimal Persistent Storage**: Only 4 user configuration settings are saved in local `UserDefaults` (`displayMode`, `bothDirectionsStyle`, `manualDirection`, `launchAtLogin`).
- **No Elevated Privileges**: Runs as a standard user process using public BSD `getifaddrs` kernel counters. Requires zero administrator privileges.

---

## 4. Measurement Methodology & Scope

- Throughput is calculated using native BSD kernel interface byte counters (`if_data.ifi_ibytes` and `if_data.ifi_obytes`) sampled at monotonic 1-second intervals.
- **Single-Interface Policy**: Monitors traffic on the primary active network interface (e.g. Wi-Fi `en0` or Ethernet `en1`). Traffic across overlapping adapters is never blindly summed together.
- **Interface Counters Scope**: Kernel interface counters measure all link-level data transferred through the active hardware interface, including local area network (LAN) transfers, file sharing, and internet traffic.

---

## 5. Installation Instructions

1. Open `ARRY-Network-Counter.dmg`.
2. Drag `ARRY Network Counter.app` into the `Applications` folder shortcut.
3. Eject the disk image.
4. Launch `ARRY Network Counter` from `/Applications` or Spotlight.
5. The throughput monitor will appear immediately in your macOS menu bar.

> [!NOTE]
> Because this release is ad-hoc signed for personal/developer testing without an Apple Developer ID certificate, Gatekeeper may display a security prompt on initial launch. Right-click `ARRY Network Counter.app` in `/Applications` and select **Open** to approve execution.

---

## 6. Known Limitations & Compatibility

- **Code Signing**: Ad-hoc signed (`codesign --sign -`). Public Gatekeeper distribution without security prompts requires Developer ID signing and Apple notarization once developer credentials are provided.
- **Apple Silicon & Intel**: Contains valid Universal Binary slices for `arm64` and `x86_64`. Tested live on Apple Silicon; execution on physical Intel hardware is Not Verified due to hardware availability.
- **Minimum macOS**: macOS 13.0 (Ventura) or newer required.
