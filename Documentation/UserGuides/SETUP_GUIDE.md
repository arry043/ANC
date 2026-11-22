# ARRY Network Counter — Setup & Installation Guide

Welcome to **ARRY Network Counter (ANC)**, a lightweight, native macOS menu-bar utility designed to provide real-time, non-intrusive network speed monitoring.

This guide provides complete instructions for system requirements, disk image installation, macOS Gatekeeper security verification, daily usage, and login startup configuration.

---

## 1. System Requirements

ARRY Network Counter is built specifically for Apple macOS, respecting native system design conventions and memory efficiency.

- **Operating System:** macOS 13.0 (Ventura) or later.
- **Hardware Architecture:** Universal binary supporting both:
  - **Apple Silicon:** `arm64` (Apple M1, M2, M3, M4 family chips).
  - **Intel:** `x86_64` (Intel-based Mac computers).
- **Distribution Format:** Standalone Apple Disk Image (`ARRY-Network-Counter.dmg`).
- **Dependencies:** None. The application is completely self-contained and does not require external frameworks, runtimes, package managers, or command-line developer tools.

---

## 2. Installation via Apple Disk Image (DMG)

To install ARRY Network Counter on your Mac:

1. **Download the Disk Image:**
   Download the official release disk image: `ARRY-Network-Counter.dmg`.

2. **Mount the Disk Image:**
   Locate the downloaded `.dmg` file in your `Downloads` folder and double-click it. macOS will mount the disk image and open a Finder window displaying the contents.

3. **Copy to Applications:**
   Drag the **ARRY Network Counter** application icon into your Mac's **Applications** folder (`/Applications`).

4. **Eject the Disk Image:**
   Once copying is complete, right-click the mounted `ARRY Network Counter` volume on your Desktop or click the Eject icon next to it in the Finder sidebar. You can now safely delete the `.dmg` file from your Downloads folder.

5. **Launch the Application:**
   Open your **Applications** folder (or press `Command + Space` for Spotlight, type *ARRY Network Counter*), and open the application.

---

## 3. First-Launch Security Approval (macOS Gatekeeper)

macOS includes a security technology called **Gatekeeper** designed to verify software origins and protect your Mac against malicious software.

### Understanding Current Signing Status

- **Development and Preview Builds:**
  Current preview and development builds of ARRY Network Counter are ad-hoc signed (`-`). They do not currently include an Apple Developer ID certificate or an Apple Cloud Notarization ticket.
- **Future Production Releases:**
  Future public releases will be signed with an official Apple Developer ID and notarized by Apple, enabling direct one-click opening.

### Standard macOS Approval Procedure

If you launch an ad-hoc signed build downloaded from the web, macOS Gatekeeper may display a prompt stating:

> *"ARRY Network Counter cannot be opened because it is from an unidentified developer"* or *"macOS cannot verify that this app is free from malware."*

To grant approval and run the application on your Mac:

#### Method A: Finder Context Menu (Recommended)
1. Open Finder and navigate to your **Applications** folder.
2. Hold down the **Control** key and click (or right-click) **ARRY Network Counter.app**.
3. Select **Open** from the top of the contextual menu.
4. A security confirmation dialog will appear. Click **Open**.
5. macOS records your approval for this application bundle; subsequent launches will open directly without repeating these steps.

#### Method B: macOS System Settings
1. If the application was blocked when you attempted to open it, open **System Settings** on your Mac.
2. Navigate to **Privacy & Security** in the sidebar.
3. Scroll down to the **Security** section.
4. You will see a notification stating: *"ARRY Network Counter was blocked from use because it is not from an identified developer."*
5. Click **Open Anyway** and enter your Mac administrator password or use Touch ID when prompted.

---

## 4. Opening and Interacting with the Application

### Menu-Bar Utility Architecture
ARRY Network Counter is architected as a native menu-bar accessory (`LSUIElement = true`):
- It **does not appear in the macOS Dock**.
- It **does not appear in the `Command + Tab` Application Switcher**.
- It lives entirely within the macOS menu bar at the top right of your screen.

### Locating the Status Item
Upon launch, ARRY Network Counter places an item in your top menu bar showing real-time throughput (for example, `↓ 0 B/s    ↑ 0 B/s` or the directional throughput for your active network connection).

### Accessing Application Controls
Click the menu-bar item to reveal the primary menu:
- **Active Interface & Status:** Displays the active network interface (such as `en0 — Wi-Fi`) and monitoring state.
- **Settings...:** Opens the native Settings window to customize display modes, login preferences, and view offline documentation.
- **Quit ARRY Network Counter:** Stops all network sampling and completely terminates the application.

---

## 5. Launch at Login Configuration

### What Launch at Login Does
When enabled, macOS automatically starts ARRY Network Counter whenever you log into your Mac user account, ensuring continuous, immediate visibility into your network throughput without needing to manually launch the app.

### How to Enable or Disable
1. Click the ARRY Network Counter item in the menu bar.
2. Select **Settings...**.
3. In the **General** section, toggle the **Launch at Login** checkbox.
4. The preference is persisted immediately to your Mac's local user preferences.

### Native macOS Integration (`SMAppService`)
On macOS 13.0 and newer, ARRY Network Counter integrates directly with Apple's modern `SMAppService.mainApp` API. This native framework replaces legacy helper tools and login-item scripts:
- It eliminates orphaned background processes.
- It cleanly registers the main application bundle with the macOS login manager.

### Managing Permissions in System Settings
In some macOS configurations, macOS may present a notification stating that a background item was added, or it may require administrative review:
- You can inspect or toggle login item permissions at any time by opening **System Settings $\rightarrow$ General $\rightarrow$ Login Items**.
- Look for **ARRY Network Counter** under the list of allowed background items.
- If macOS requires user approval, the ANC Settings interface will display an orange warning with a direct button: **Open Login Items Settings**.

### Monitoring Lifecycle Notice
Network throughput calculations and kernel counter sampling occur **only while ARRY Network Counter is running**. If the application is quit or Launch at Login is disabled, zero background daemons, daemons-on-demand, or telemetry services remain active on your Mac.
