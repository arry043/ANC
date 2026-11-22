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
    subtitle: "Intelligent Direction Switching",
    description:
      "ANC automatically highlights whichever direction currently has higher network traffic, with smart anti-flicker stability to keep your menu bar calm during balanced connections.",
    badge: "Smart Switching",
    specs: ["Automatic traffic detection", "Built-in anti-flicker stability", "Smooth direction handover", "Clean 0 KB/s baseline when idle"],
    visualType: "single-auto",
  },
  {
    id: "performance-privacy",
    title: "Native Performance & Privacy",
    subtitle: "Lightweight, silent, and battery-friendly",
    description:
      "Designed natively for macOS to run silently in your menu bar. Zero telemetry, zero webviews, zero tracking, and an ultra-lightweight CPU footprint under 0.4%.",
    badge: "Privacy First",
    specs: ["Under 0.4% typical CPU usage", "Zero data collection or tracking", "Runs completely offline", "Native macOS energy efficiency"],
    visualType: "specs-list",
  },
];
