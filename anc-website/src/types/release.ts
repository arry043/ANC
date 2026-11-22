import { z } from "zod";

export type DisplayMode = "bothDirections" | "singleDirectionManual" | "singleDirectionAutomatic";
export type BothDirectionsStyle = "separateSpeeds" | "combinedArrows" | "withoutArrows";
export type SingleDirectionArrowStyle = "withArrow" | "withoutArrows";
export type NetworkDirection = "download" | "upload";

export interface ANCRelease {
  version: string;
  build: string;
  releaseDate: string;
  minimumMacOS: string;
  architectures: string[];
  filename: string;
  fileSizeBytes: number;
  formattedSize: string;
  sha256: string;
  downloadUrl: string;
  checksumUrl: string;
  releaseNotesUrl?: string;
  channel: "stable" | "beta";
  isLatest: boolean;
  signingStatus: "ad-hoc" | "developer-id" | "notarized";
  highlights: string[];
}

export interface ANCReleaseManifest {
  product: string;
  shortName: string;
  bundleId: string;
  latestVersion: string;
  releases: ANCRelease[];
}
