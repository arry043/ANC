import { z } from "zod";

export const ANCReleaseSchema = z.object({
  version: z.string().regex(/^\d+\.\d+\.\d+$/),
  build: z.string(),
  releaseDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  minimumMacOS: z.string(),
  architectures: z.array(z.string()).min(1),
  filename: z.string().endsWith(".dmg"),
  fileSizeBytes: z.number().positive(),
  formattedSize: z.string(),
  sha256: z.string().length(64),
  downloadUrl: z.string().url(),
  checksumUrl: z.string().url(),
  releaseNotesUrl: z.string().url().optional(),
  channel: z.enum(["stable", "beta"]),
  isLatest: z.boolean(),
  signingStatus: z.enum(["ad-hoc", "developer-id", "notarized"]),
  highlights: z.array(z.string()),
});

export const ANCReleaseManifestSchema = z.object({
  product: z.string(),
  shortName: z.string(),
  bundleId: z.string(),
  latestVersion: z.string(),
  releases: z.array(ANCReleaseSchema).min(1),
});

export function validateReleaseManifest(data: unknown) {
  return ANCReleaseManifestSchema.safeParse(data);
}
