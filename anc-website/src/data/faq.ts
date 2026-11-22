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
      "ANC requires macOS Ventura (13.0) or later, including macOS Sonoma and macOS Sequoia.",
  },
  {
    category: "general",
    question: "Does ANC support both Apple Silicon and Intel Macs?",
    answer:
      "Yes. ARRY Network Counter runs natively on all Apple Silicon (M1, M2, M3, M4) and Intel-based Mac computers.",
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
      "ANC includes intelligent anti-flicker protection that waits for consistent traffic before switching directions, preventing distracting jumps in your menu bar when download and upload rates are nearly balanced.",
  },
  {
    category: "general",
    question: "Does ANC appear in the macOS Dock or App Switcher?",
    answer:
      "No. ANC lives quietly in your top menu bar and does not clutter your Dock or the Command-Tab application switcher.",
  },
  {
    category: "technical",
    question: "Does ANC require administrator or root privileges?",
    answer:
      "No. ANC runs as a standard Mac app and does not require administrator privileges or root access.",
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
      "ANC measures actual data moving across your active network interface (such as Wi-Fi or Ethernet). Because it monitors all link-level traffic, local transfers (AirDrop, local NAS file copies, Time Machine network backups) and internet traffic both contribute to total throughput. ANC is an interface throughput monitor, not a synthetic internet speed test.",
  },
  {
    category: "technical",
    question: "What unit standards are used for speed calculations?",
    answer:
      "ANC uses standard decimal units matching macOS: 1 KB/s = 1,000 B/s and 1 MB/s = 1,000,000 B/s. Idle state is shown cleanly as 0 KB/s.",
  },
  {
    category: "features",
    question: "How do I enable Launch at Login?",
    answer:
      "Open ARRY Network Counter Settings from the menu-bar item. In the General section, check the 'Launch at Login' box to start automatically whenever you sign in to macOS.",
  },
  {
    category: "troubleshooting",
    question: "Why does macOS Gatekeeper show a security prompt on first launch?",
    answer:
      "To open: right-click (or Control-click) ARRY Network Counter.app in your Applications folder, choose 'Open', and confirm 'Open' in the dialog. Alternatively, approve it in macOS System Settings > Privacy & Security > Security.",
  },
  {
    category: "general",
    question: "How do I update ARRY Network Counter?",
    answer:
      "Download the new release DMG, open the disk image, and drag the application to your Applications folder, choosing 'Replace' when prompted. Your display preferences will remain preserved automatically.",
  },
  {
    category: "troubleshooting",
    question: "How do I completely uninstall ANC?",
    answer:
      "To uninstall: quit ANC from the menu bar, then drag ARRY Network Counter from your Applications folder to the Trash.",
  },
];
