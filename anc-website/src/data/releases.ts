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
      "Initial general release of ARRY Network Counter",
      "Native menu-bar throughput monitoring for macOS 13.0+ (Ventura, Sonoma, Sequoia)",
      "Universal Binary: full native slices for Apple Silicon (arm64) and Intel (x86_64)",
      "Four distinct display modes with 3-factor hysteresis switching",
      "SI decimal byte speed scaling (1 KB/s = 1,000 B/s)",
      "Native Launch at Login integration via SMAppService",
      "Offline documentation bundled directly into Settings",
      "Zero telemetry, zero external network connections, zero analytics",
      "Ultra-lightweight steady-state CPU footprint under 0.4%"
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
