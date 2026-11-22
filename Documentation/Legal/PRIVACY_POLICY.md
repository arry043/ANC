# ARRY Network Counter — Privacy Policy

**Effective Date:** January 1, 2026  
**Product:** ARRY Network Counter (ANC)  
**Brand & Provider:** ARRRY  

ARRRY ("we", "us", or "our") has developed **ARRY Network Counter (ANC)** with an architecture centered on privacy, local device processing, and operational transparency.

This Privacy Policy describes how ARRY Network Counter handles data when you run the application on macOS. Every statement in this policy is directly backed by source-code verification.

---

## 1. Summary of Data Practices

| Category | Application Behavior |
|:---|:---|
| **Remote Network Transmission** | **None.** The application makes zero outbound or inbound network connections. |
| **Telemetry & Analytics** | **None.** No analytics SDKs, trackers, or telemetry reporting tools are bundled. |
| **Crash Reporting** | **None.** No crash-reporting frameworks or remote diagnostic loggers are used. |
| **Personal Information (PII)** | **None.** No names, email addresses, IP addresses, or device identifiers are collected. |
| **Network Traffic Inspection** | **None.** Packet payloads, visited URLs, DNS requests, and content are never accessed. |
| **Throughput Processing** | **In-Memory Only.** Kernel byte counters are evaluated in volatile RAM and discarded. |
| **Persistent Storage** | **Local Preferences Only.** 4 user configuration settings saved in `UserDefaults`. |

---

## 2. In-Memory Throughput Processing

To calculate and display your network speeds, ARRY Network Counter queries standard macOS kernel network statistics via the operating system's BSD `getifaddrs` interface.

### What Is Evaluated
- **Cumulative Byte Counters:** The application reads cumulative received (`ifi_ibytes`) and transmitted (`ifi_obytes`) byte totals reported by the operating system for network interfaces (e.g., `en0`).
- **Path State:** The application monitors interface connectivity (Wi-Fi, Ethernet, Loopback, Other) using Apple's `NWPathMonitor`.
- **Elapsed Time:** High-resolution monotonic system time (`clock_gettime_nsec_np`) is used to calculate speed as the difference in bytes divided by elapsed seconds ($\Delta\text{bytes} / \Delta t$).

### What Is NOT Evaluated or Accessed
- The application **does not** perform packet inspection or packet sniffing.
- The application **does not** read packet headers or payloads.
- The application **does not** record visited websites, URLs, domains, or web traffic.
- The application **does not** monitor DNS lookups, ports, or protocols.
- The application **does not** log the IP addresses of other computers with which you communicate.

### Volatile Retention
All speed measurements and snapshot deltas exist strictly in volatile RAM. They are continuously overwritten as new 1-second samples arrive and are completely purged from memory when the application is quit. No history or logs of throughput are written to disk.

---

## 3. Local Storage (`UserDefaults`)

ARRY Network Counter persists only application configuration settings locally on your Mac using standard macOS `UserDefaults` in the application's domain (`in.arrry.networkcounter`).

The four persisted preference values are:

1. `displayMode`: Your selected presentation mode (`bothDirections`, `singleDirectionManual`, or `singleDirectionAutomatic`).
2. `bothDirectionsStyle`: Your selected presentation style (`separateSpeeds` or `combinedArrows`).
3. `manualDirection`: Your selected direction for manual mode (`download` or `upload`).
4. `launchAtLogin`: A boolean flag (`true` or `false`) reflecting whether login item launch was requested.

No personal data, device identifiers, or usage logs are ever stored in `UserDefaults` or on your filesystem.

---

## 4. Network Activity & External Connectivity

**ARRY Network Counter does not connect to the internet or any local network service.**

- The application contains **zero HTTP/HTTPS clients**, `URLSession` instances, socket connections, or web views.
- The application **never transmits** telemetry, diagnostics, system metrics, hardware details, or preference data to ARRRY, Apple, or any third party.
- The application functions entirely offline. An active internet connection is neither required nor utilized by the application's internal code.

---

## 5. Third-Party Services and Frameworks

- **No Third-Party SDKs:** ARRY Network Counter contains no third-party libraries, advertising SDKs, analytics trackers, or commercial frameworks.
- **Native Apple Frameworks:** The application relies exclusively on standard Apple system frameworks provided directly by macOS (`Foundation`, `AppKit`, `SwiftUI`, `Network`, and `ServiceManagement`).

---

## 6. Launch at Login Integration

When you enable the **Launch at Login** preference, ARRY Network Counter interacts directly with Apple's `SMAppService.mainApp` API.

- This registration is managed natively by macOS.
- ARRY Network Counter does not install background launch daemons (`launchd` daemons), privileged helper tools, or kernel extensions.
- You can review and revoke login permissions at any time via **System Settings $\rightarrow$ General $\rightarrow$ Login Items**.

---

## 7. User Control, Data Removal, and Reset

You retain complete control over your application settings:

- **Modifying Settings:** You can alter all display modes and startup behaviors at any time through the **Settings** window.
- **Resetting Stored Preferences:** To remove all saved application preferences, you can execute the following standard command in the macOS Terminal:
  ```bash
  defaults delete in.arrry.networkcounter
  ```
- **Uninstalling the Application:** Deleting `ARRY Network Counter.app` from your `/Applications` folder removes the executable. Any previously registered login item is deactivated by macOS upon application deletion.

---

## 8. Children's Privacy

ARRY Network Counter is a general-purpose utility that does not collect, solicit, or store personal information from any user, including children under the age of 13.

---

## 9. Policy Updates

We may update this Privacy Policy periodically to reflect potential application enhancements or changes in legal requirements. Any modifications will be documented in the application release notes and bundled directly within the offline documentation included with new versions of the application.

---

## 10. Contact & Privacy Inquiries

*Notice on Verification:*  
Specific entity registration details and legal contact channels require project owner confirmation. For security disclosures or technical privacy inquiries related to this codebase, please submit an issue through the official ARRRY project repository.
