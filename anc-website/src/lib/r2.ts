/**
 * Cloudflare R2 Release Storage Architecture
 *
 * Bucket: arrry
 * Public Domain: https://downloads.arrry.in
 * Release Directory: anc/releases/
 *
 * Object hierarchy:
 * arrry/
 *   anc/
 *     releases/
 *       v1.0.0/
 *         ARRY-Network-Counter.dmg
 *         SHA256SUMS.txt
 *         RELEASE_NOTES.md
 *       latest.json
 */

export interface R2Config {
  bucketName: string;
  publicBaseUrl: string;
  releasePrefix: string;
  s3Endpoint?: string;
}

export function getR2Config(): R2Config {
  return {
    bucketName: process.env.R2_BUCKET_NAME || "arrry",
    publicBaseUrl: (process.env.R2_PUBLIC_BASE_URL || "https://downloads.arrry.in").replace(/\/$/, ""),
    releasePrefix: "anc/releases",
    s3Endpoint: process.env.R2_S3_ENDPOINT,
  };
}

export function getReleaseObjectKey(version: string, filename: string): string {
  const cleanVersion = version.startsWith("v") ? version : `v${version}`;
  return `anc/releases/${cleanVersion}/${filename}`;
}

export function getPublicDownloadUrl(version: string, filename: string = "ARRY-Network-Counter.dmg"): string {
  const config = getR2Config();
  const key = getReleaseObjectKey(version, filename);
  return `${config.publicBaseUrl}/${key}`;
}

export function getReleaseChecksumUrl(version: string): string {
  return getPublicDownloadUrl(version, "SHA256SUMS.txt");
}

export function getReleaseNotesUrl(version: string): string {
  return getPublicDownloadUrl(version, "RELEASE_NOTES.md");
}
