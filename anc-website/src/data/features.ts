export interface ANCFeature {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  badge?: string;
  specs?: string[];
  visualType: "both-separate" | "both-combined" | "both-text" | "single-manual" | "single-auto" | "specs-list";
}

export const featuresList: ANCFeature[] = [
  {
    id: "both-separate",
    title: "Both Directions — Separate Speeds",
    subtitle: "Real-Time Independent Throughput",
    description:
      "Simultaneously monitor incoming download and outgoing upload speeds in real-time. Features distinct semantic green download and blue upload directional arrows with monospaced digits to eliminate layout jitter.",
    badge: "Default Mode",
    specs: ["Download in emerald green (↓)", "Upload in electric blue (↑)", "4-space fixed tabular separation", "Monospaced font weights"],
    visualType: "both-separate",
  },
  {
    id: "both-combined",
    title: "Both Directions — Combined Arrows",
    subtitle: "Ultra-Compact Dual Indicator",
    description:
      "Displays dual arrows (↓ ↑) while focusing menu bar space on a single numerical speed representing the currently dominant traffic direction. Hysteresis switching ensures seamless transitions.",
    badge: "Minimalist Space Saver",
    specs: ["Dual persistent arrow glyphs", "Single dominant throughput number", "Smooth direction handover", "Ideal for crowded menu bars"],
    visualType: "both-combined",
  },
  {
    id: "both-text",
    title: "Both Directions — Without Arrows",
    subtitle: "Clean Typographic Text Labels",
    description:
      "Prefer letters over symbols? Display independent speeds preceded by compact DL and UL text indicators with semibold styling and high-contrast color coding.",
    badge: "Typographic Alternative",
    specs: ["Green 'DL' label for downloads", "Blue 'UL' label for uploads", "No arrow glyphs", "High readability across displays"],
    visualType: "both-text",
  },
  {
    id: "single-manual",
    title: "Single Direction — Manual",
    subtitle: "Pinned Single Traffic Stream",
    description:
      "Lock your menu bar display strictly to Download or Upload. Selected direction remains active continuously, completely ignoring opposing traffic spikes. Includes optional arrow visibility.",
    badge: "Focused Monitoring",
    specs: ["User chooses Download or Upload", "Toggle arrow glyphs on or off", "Opposing traffic is ignored", "Great for ongoing large file transfers"],
    visualType: "single-manual",
  },
  {
    id: "single-auto",
    title: "Single Direction — Automatic",
    subtitle: "Intelligent 3-Factor Hysteresis Engine",
    description:
      "ANC dynamically switches to display whichever direction currently carries the dominant throughput. Protected by a deterministic 3-factor hysteresis engine to prevent visual flapping or flickering during balanced connections.",
    badge: "Intelligent Switching",
    specs: ["10% relative speed margin requirement", "10 KB/s absolute noise floor threshold", "2 consecutive sample confirmation", "Defaults to ↓ 0 KB/s when idle"],
    visualType: "single-auto",
  },
  {
    id: "performance-privacy",
    title: "Native Architecture & Privacy",
    subtitle: "Engineered in Swift 6 for Zero Bloat",
    description:
      "Built natively with SwiftUI, AppKit, and BSD kernel interface statistics (getifaddrs). Zero telemetry, zero webviews, zero background analytics, and an average CPU footprint under 0.4%.",
    badge: "Privacy Guarantee",
    specs: ["Under 0.4% steady-state CPU usage", "Universal Binary (Apple Silicon + Intel)", "Zero external network connections", "4 preference values in UserDefaults only"],
    visualType: "specs-list",
  },
];

export const technicalSpecs = [
  { label: "Application Name", value: "ARRY Network Counter" },
  { label: "Short Name", value: "ANC" },
  { label: "Current Version", value: "1.0.0 (Build 1)" },
  { label: "Release Date", value: "November 22, 2026" },
  { label: "Operating System", value: "macOS 13.0+ (Ventura, Sonoma, Sequoia)" },
  { label: "Architectures", value: "Universal Binary (arm64 Apple Silicon + x86_64 Intel)" },
  { label: "Distribution Package", value: "Apple Disk Image (DMG) · 5.3 MB" },
  { label: "Bundle Identifier", value: "in.arrry.networkcounter" },
  { label: "Application Type", value: "Native Menu-Bar Accessory (LSUIElement)" },
  { label: "Code Signing", value: "Ad-hoc signed (Developer ID notarization pending)" },
  { label: "Measurement Sampling", value: "Monotonic 1-second interval kernel counters" },
  { label: "Throughput Units", value: "Base-1000 SI Decimal (1 KB/s = 1,000 B/s)" },
  { label: "Persistence", value: "4 local keys in NSUserDefaults (zero telemetry)" },
  { label: "Startup Integration", value: "Apple SMAppService.mainApp (macOS Login Items)" },
];
