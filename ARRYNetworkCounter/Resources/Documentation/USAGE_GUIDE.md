# ARRY Network Counter — User & Operations Guide

Welcome to the **ARRY Network Counter (ANC)** User Guide. This document details the application's real-time monitoring capabilities, display modes, automatic direction switching logic, unit standards, and operational measurement characteristics.

---

## 1. Introduction

**ARRY Network Counter (ANC)** is a lightweight, native macOS menu-bar utility that displays your computer's real-time download and upload network throughput.

### How It Works
ANC monitors active network traffic by periodically querying macOS kernel interface counters (`getifaddrs`). By calculating the difference in cumulative transmitted and received byte counts divided by the elapsed sampling time, ANC presents accurate instantaneous throughput directly in your menu bar.

### What ANC Is Not
- **Not an Internet Speed Test:** ANC does not perform artificial speed tests, download test payloads, ping remote test servers, or consume your internet bandwidth.
- **Not a Bandwidth Quota Tracker:** ANC does not maintain historical traffic logs or track monthly internet data usage caps.
- **Instantaneous Real-Time Measurement:** ANC reflects the actual data currently moving through your Mac's active network hardware.

---

## 2. Display Modes & Presentation Styles

ANC provides four customizable display configurations tailored to your preference and menu-bar space. You can configure your preferred mode at any time in **Settings $\rightarrow$ Display Mode**.

### 1. Both Directions — Separate Speeds (Default)

Displays both download and upload speeds simultaneously and independently.

**Visual Representation:**
```text
↓ 2.45 MB/s    ↑ 120 KB/s
```

- **Download:** Indicated with a green downward arrow (`↓`) followed by the download speed.
- **Upload:** Indicated with a blue upward arrow (`↑`) followed by the upload speed.
- **Separation:** Speeds are separated with subtle fixed spacing for high legibility at glance.
- **Best For:** Users who require concurrent, independent monitoring of both incoming and outgoing traffic.

---

### 2. Both Directions — Combined Arrows

Displays both direction indicators together while showing only the speed of the currently dominant direction.

**Visual Representation:**
```text
↓ ↑ 2.45 MB/s
```

- **Indicators:** Both the green downward arrow (`↓`) and blue upward arrow (`↑`) remain visible.
- **Single Numerical Value:** Shows the numerical speed of whichever direction is currently carrying higher traffic.
- **Dynamic Transition:** When upload exceeds download, the displayed speed automatically reflects the upload throughput.
- **Best For:** Users who want a compact display showing dual activity while conserving menu-bar width.

---

### 3. Both Directions — Without Arrows

Displays independent download and upload speeds using compact letter labels instead of directional arrow glyphs.

**Visual Representation:**
```text
DL 2.45 MB/s    UL 120 KB/s
```

- **Download:** Indicated with a green `DL` text label followed by the download speed.
- **Upload:** Indicated with a blue `UL` text label followed by the upload speed.
- **Separation:** Speeds are separated with fixed spacing (4 spaces) for clean readability.
- **Best For:** Users who prefer typographic letter abbreviations without arrow icons.

---

### 4. Single Direction — Manual

Displays exclusively the direction manually chosen by the user, with optional arrow visibility.

**With Arrow Representation:**
```text
Download:  ↓ 2.45 MB/s
Upload:    ↑ 120 KB/s
```

**Without Arrows Representation:**
```text
Download:  2.45 MB/s
Upload:    120 KB/s
```

- **User Control:** Select either **Download** or **Upload** in Settings.
- **Arrow Visibility:** Choose between **With Arrow** and **Without Arrows**.
- **Fixed Display:** The chosen direction remains locked in the menu bar. Automatic dominance changes will not override your selection.
- **Best For:** Users monitoring specific tasks, such as large file downloads, streaming, or video uploads.

---

### 5. Single Direction — Automatic

Dynamically displays whichever direction is actively dominating network throughput using intelligent hysteresis switching, with optional arrow visibility.

**With Arrow Representation:**
```text
↓ 2.45 MB/s   (switches to ↑ 1.20 MB/s when upload dominates)
```

**Without Arrows Representation:**
```text
2.45 MB/s     (switches to 1.20 MB/s when upload dominates)
```

- **Dynamic Direction:** Shows a single speed value corresponding to the dominant direction.
- **Arrow Visibility:** Choose between **With Arrow** and **Without Arrows**.
- **Intelligent Switching:** Automatically transitions between download and upload as network demands shift.
- **Best For:** Users seeking maximum menu-bar space efficiency with zero manual intervention.

---

## 3. Automatic Direction Switching Architecture

When using **Both Directions — Combined Arrows** or **Single Direction — Automatic**, ANC evaluates traffic dominance using a multi-factor hysteresis engine.

### Why Hysteresis Is Essential
Network traffic naturally fluctuates from millisecond to millisecond. Without hysteresis, speeds with near-equal throughput would cause rapid, distracting visual flickering in the menu bar.

ANC resolves this with three codified switching rules:

1. **Relative Margin (10%):**
   To challenge the currently active direction, the competing direction's speed must exceed the active direction by at least **10%**.
   $$\text{Speed}_{\text{candidate}} > \text{Speed}_{\text{active}} \times 1.10$$

2. **Absolute Threshold (10,000 B/s):**
   A direction switch is only considered if the candidate speed is at least **10,000 Bytes per second (10 KB/s)**. Minor background protocol traffic (such as keep-alive packets) cannot trigger direction switches.

3. **Confirmation Window (2 Consecutive Samples):**
   A qualifying condition must be sustained across **two consecutive 1-second sampling cycles** before the display switches. Transient, single-packet spikes are filtered out.

### Idle Traffic State
When network activity in both directions falls below the 10,000 B/s threshold:
- The connection is classified as **idle**.
- The display smoothly settles on the **Download** direction by default (`↓ 0 B/s`).

---

## 4. Supported Speed Units & Numerical Standards

ANC uses standard SI decimal multipliers (powers of 10) for all throughput measurements:

| Unit | Full Name | Byte Value (B/s) |
|:---|:---|---:|
| **B/s** | Bytes per second | $1\text{ B/s}$ |
| **KB/s** | Kilobytes per second | $1,000\text{ B/s}$ |
| **MB/s** | Megabytes per second | $1,000,000\text{ B/s}$ |
| **GB/s** | Gigabytes per second | $1,000,000,000\text{ B/s}$ |
| **TB/s** | Terabytes per second | $1,000,000,000,000\text{ B/s}$ |

### Critical Difference: Bytes per Second (B/s) vs. Bits per Second (bps)

Please note that **ANC displays Bytes per second (B/s), NOT bits per second (bps)**:

- **1 Byte (B) = 8 bits (b).**
- Internet Service Providers (ISPs) advertise connection speeds in **Megabits per second (Mbps)** or **Gigabits per second (Gbps)**.
- File downloads, browser transfers, and operating system statistics are measured in **Megabytes per second (MB/s)** or **Gigabytes per second (GB/s)**.

**Comparison Example:**
A 100 Mbps internet connection theoretical maximum download speed is:
$$\frac{100\text{ Mbps}}{8} = 12.5\text{ MB/s}$$
Therefore, if ANC displays `12.5 MB/s`, you are fully utilizing a 100 Mbps broadband connection.

---

## 5. Operational Characteristics & Measurement Limitations

To interpret ANC's readings accurately, keep the following operating characteristics in mind:

### Baseline Establishment
When ANC launches, or when your Mac switches networks, the first 1-second sample establishes a mathematical baseline. Speed readings begin rendering accurately upon the second sample ($t = 1\text{s}$).

### Kernel Interface Statistics
Speeds are computed directly from the macOS BSD network stack via `getifaddrs`. The measurements reflect actual physical/logical network frame transfers processed by the kernel.

### Local Network (LAN) vs. Internet (WAN) Traffic
ANC measures all traffic routed through your Mac's primary active network adapter. This includes:
- Internet browsing and downloads.
- Local Area Network (LAN) traffic, including:
  - Apple AirDrop transfers.
  - Time Machine network backups.
  - Local NAS (Network Attached Storage) file copies.
  - Local media streaming (AirPlay, Plex, etc.).

If you perform an AirDrop or local file transfer over Wi-Fi, ANC will reflect the high local transfer speeds across the Wi-Fi interface.

### VPNs, Virtual Interfaces, and Bridges
- **Virtual Interfaces:** If your Mac routes traffic through a VPN tunnel interface (e.g. `utun3`), ANC's interface selector tracks the primary default route designated by macOS `NWPathMonitor`.
- Depending on the VPN client software and routing tables, throughput may be captured at either the physical interface or the virtual tunnel interface.

### Zero Bandwidth Overhead
Because ANC reads hardware byte counters already tracked by the macOS kernel, the application generates **zero synthetic network traffic**. Monitoring creates virtually no CPU overhead and consumes negligible battery life.
