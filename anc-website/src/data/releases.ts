import { ANCRelease, ANCReleaseManifest } from "@/types/release";
import { ANCReleaseManifestSchema } from "@/lib/release-validation";

export const releasesData: ANCRelease[] = [
  {
    version: "1.0.0",
    build: "1",
    releaseDate: "2026-11-22",
    minimumMacOS: "13.0+",
    architectures: ["arm64", "x86_64"],
    filename: "ARRY-Network-Counter.dmg",
    fileSizeBytes: 5304733,
    formattedSize: "5.3 MB",
    sha256: "4b8def5255624fcc682ff34df820c0ee7cc7ac09562a81639539b4e2448881a4",
    downloadUrl: "https://downloads.arrry.in/anc/releases/v1.0.0/ARRY-Network-Counter.dmg",
    checksumUrl: "https://downloads.arrry.in/anc/releases/v1.0.0/SHA256SUMS.txt",
    releaseNotesUrl: "https://downloads.arrry.in/anc/releases/v1.0.0/RELEASE_NOTES.md",
    channel: "stable",
    isLatest: true,
    signingStatus: "ad-hoc",
    highlights: [
      "Real-time download and upload speed monitoring directly in your macOS menu bar.",
      "Multiple display modes: separate speeds, combined arrows, or direction only.",
      "Automatic and manual direction selection with smooth anti-flicker protection.",
      "Launch at Login support to start automatically with macOS.",
      "Offline documentation and user guides built directly into Settings.",
      "100% private: zero data collection, zero network tracking, and minimal battery impact."
    ]
  }
];

export const releaseManifest: ANCReleaseManifest = {
  product: "ARRY Network Counter",
  shortName: "ANC",
  bundleId: "in.arrry.networkcounter",
  latestVersion: "1.0.0",
  releases: releasesData,
};

// Validate manifest at compile/runtime
const validation = ANCReleaseManifestSchema.safeParse(releaseManifest);
if (!validation.success) {
  console.error("Release manifest validation failed:", validation.error.format());
}

export const latestRelease = releasesData.find((r) => r.isLatest) || releasesData[0];
export const previousReleases = releasesData.filter((r) => !r.isLatest);
