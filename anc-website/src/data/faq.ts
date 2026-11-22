export interface FAQItem {
  question: string;
  answer: string;
  category: "general" | "features" | "technical" | "privacy" | "troubleshooting";
}

export const faqItems: FAQItem[] = [
  {
    category: "general",
    question: "What is ARRY Network Counter (ANC)?",
    answer:
      "ARRY Network Counter is a lightweight, native macOS menu-bar utility designed to monitor and display your real-time network download and upload throughput directly in the macOS menu bar without background bloat or battery drain.",
  },
  {
    category: "general",
    question: "Which macOS versions are supported?",
    answer:
      "ANC requires macOS 13.0 (Ventura) or later, including macOS 14 (Sonoma) and macOS 15 (Sequoia). It leverages modern macOS frameworks including SwiftUI, AppKit, Network.framework, and SMAppService.",
  },
  {
    category: "general",
    question: "Does ANC support both Apple Silicon and Intel Macs?",
    answer:
      "Yes. ARRY Network Counter is compiled as an Apple Universal Binary containing native 64-bit slices for both Apple Silicon (arm64: M1, M2, M3, M4 family) and Intel (x86_64) Mac computers. It runs natively without requiring Rosetta 2 translation.",
  },
  {
    category: "features",
    question: "Does it monitor both download and upload speeds?",
    answer:
      "Yes. ANC supports four customizable display modes: Both Directions with Separate Speeds (simultaneous download and upload), Both Directions with Combined Arrows (dual arrows showing the active dominant rate), Single Direction Manual (pinned to download or upload), and Single Direction Automatic (dynamically switching with traffic dominance).",
  },
  {
    category: "features",
    question: "How does ANC prevent menu-bar flickering during balanced traffic?",
    answer:
      "ANC incorporates a deterministic 3-factor hysteresis engine: the opposing direction must exceed the active speed by at least a 10% relative margin and a 10 KB/s absolute noise floor across 2 consecutive 1-second sample intervals. This eliminates rapid visual flapping when speeds are nearly equal.",
  },
  {
    category: "general",
    question: "Does ANC appear in the macOS Dock or App Switcher?",
    answer:
      "No. ANC is intentionally configured as a background menu-bar accessory (`LSUIElement = true`). It resides entirely in your top menu bar and does not clutter your Dock or the Command-Tab application switcher.",
  },
  {
    category: "technical",
    question: "Does ANC require administrator or root privileges?",
    answer:
      "No. ANC runs entirely as a standard unprivileged user process. It queries standard BSD kernel network interface counters (`getifaddrs`), which are public system statistics accessible without root or administrator elevation.",
  },
  {
    category: "privacy",
    question: "Does ANC store network history or inspect my web traffic?",
    answer:
      "Absolutely not. ANC performs zero packet inspection, zero payload analysis, and records zero browsing history, URLs, or IP addresses. Throughput calculations are evaluated purely in volatile RAM at 1-second intervals and discarded. ANC contains zero external network calls, zero telemetry, and zero third-party analytics SDKs.",
  },
  {
    category: "technical",
    question: "Why can local network transfers affect the speed readings?",
    answer:
      "ANC measures actual throughput traversing your Mac's active network hardware interface (such as Wi-Fi `en0` or Ethernet `en1`). Because kernel interface counters measure all link-level data, local file transfers (AirDrop, NAS, Time Machine over network) and internet traffic both contribute to total link throughput. ANC is an interface throughput monitor, not a synthetic internet speed test.",
  },
  {
    category: "technical",
    question: "What unit standards are used for speed calculations?",
    answer:
      "ANC strictly adopts standard macOS decimal SI units (base 1000): 1 KB/s = 1,000 B/s and 1 MB/s = 1,000,000 B/s. Values are presented in Bytes per second (8 bits = 1 Byte) formatted with up to 2 decimal places and trailing zero trimming (e.g. 1.5 MB/s). Idle state is displayed as 0 KB/s.",
  },
  {
    category: "features",
    question: "How do I enable Launch at Login?",
    answer:
      "Open ARRY Network Counter Settings from the menu-bar item. In the General section, check the 'Launch at Login' box. ANC uses Apple's modern `SMAppService.mainApp` API to register natively with macOS Login Items without installing background daemons or helper tools.",
  },
  {
    category: "troubleshooting",
    question: "Why does macOS Gatekeeper show a security prompt on first launch?",
    answer:
      "Current v1.0.0 builds are ad-hoc signed for personal and preview testing and have not yet been signed with a commercial Apple Developer ID certificate. To open: right-click (or Control-click) ARRY Network Counter.app in your Applications folder, choose 'Open', and confirm 'Open' in the dialog. Alternatively, approve it in macOS System Settings > Privacy & Security > Security.",
  },
  {
    category: "general",
    question: "How do I update ARRY Network Counter?",
    answer:
      "Download the new release DMG from the official ARRRY download center (`anc.arrry.in/download`), open the disk image, and drag the updated application to your Applications folder, selecting 'Replace' when prompted. Your four saved preferences in UserDefaults will remain preserved.",
  },
  {
    category: "troubleshooting",
    question: "How do I completely uninstall ANC and remove saved settings?",
    answer:
      "To uninstall: quit ANC from the menu bar, delete `ARRY Network Counter.app` from `/Applications`, and if you wish to reset saved display preferences, run `defaults delete in.arrry.networkcounter` in the macOS Terminal.",
  },
];
