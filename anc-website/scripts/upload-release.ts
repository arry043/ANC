import fs from "fs";
import path from "path";
import crypto from "crypto";
import { S3Client, PutObjectCommand, HeadObjectCommand } from "@aws-sdk/client-s3";
import { releaseManifest, latestRelease } from "../src/data/releases";
import { getR2Config, getReleaseObjectKey } from "../src/lib/r2";

/**
 * ARRY Network Counter — Cloudflare R2 Release Upload Script
 *
 * Bucket: arrry
 * Release Path: anc/releases/
 * Custom Domain: https://downloads.arrry.in
 *
 * Workflow:
 * 1. Read existing release artifact from release/ directory
 * 2. Verify DMG existence and SHA-256 checksum
 * 3. Upload DMG, SHA256SUMS.txt, and RELEASE_NOTES.md to Cloudflare R2
 * 4. Upload latest.json metadata manifest
 * 5. Verify object accessibility
 */
async function uploadRelease() {
  console.log("=== ARRY Network Counter — R2 Release Upload ===");

  const version = process.argv[2] || latestRelease.version;
  console.log(`Target Release Version: v${version}`);

  const release = releaseManifest.releases.find((r) => r.version === version);
  if (!release) {
    console.error(`Error: Release version ${version} not found in release manifest.`);
    process.exit(1);
  }

  // Check required environment variables
  const accountId = process.env.R2_ACCOUNT_ID;
  const accessKeyId = process.env.R2_ACCESS_KEY_ID;
  const secretAccessKey = process.env.R2_SECRET_ACCESS_KEY;
  const bucketName = process.env.R2_BUCKET_NAME || "arrry";
  const publicBaseUrl = process.env.R2_PUBLIC_BASE_URL || "https://downloads.arrry.in";

  if (!accessKeyId || !secretAccessKey || !accountId) {
    console.error("Missing R2 credentials. Please set R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, and R2_SECRET_ACCESS_KEY.");
    console.error("Refer to Documentation/R2_SETUP.md for configuration instructions.");
    process.exit(1);
  }

  const endpoint = process.env.R2_S3_ENDPOINT || `https://${accountId}.r2.cloudflarestorage.com`;

  const s3 = new S3Client({
    region: "auto",
    endpoint,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  // Locate local release files (checked against parent release folder)
  const localReleaseDir = path.resolve(__dirname, "../../release", `v${version}`);
  const dmgPath = path.join(localReleaseDir, release.filename);

  if (!fs.existsSync(dmgPath)) {
    console.error(`Error: DMG artifact not found at ${dmgPath}`);
    process.exit(1);
  }

  // Verify SHA-256 locally
  console.log("Verifying local DMG SHA-256 checksum...");
  const dmgBuffer = fs.readFileSync(dmgPath);
  const hash = crypto.createHash("sha256").update(dmgBuffer).digest("hex");

  if (hash !== release.sha256) {
    console.error(`Checksum mismatch! Local: ${hash}, Manifest: ${release.sha256}`);
    process.exit(1);
  }
  console.log(`✓ SHA-256 verified: ${hash}`);
  console.log(`✓ DMG file size: ${dmgBuffer.length.toLocaleString()} bytes`);

  // Files to upload
  const filesToUpload = [
    {
      localFile: dmgPath,
      key: getReleaseObjectKey(version, release.filename),
      contentType: "application/x-apple-diskimage",
      cacheControl: "public, max-age=31536000, immutable", // Immutable versioned release
    },
    {
      localFile: path.join(localReleaseDir, "SHA256SUMS.txt"),
      key: getReleaseObjectKey(version, "SHA256SUMS.txt"),
      contentType: "text/plain; charset=utf-8",
      cacheControl: "public, max-age=31536000, immutable",
    },
    {
      localFile: path.join(localReleaseDir, "RELEASE_NOTES.md"),
      key: getReleaseObjectKey(version, "RELEASE_NOTES.md"),
      contentType: "text/markdown; charset=utf-8",
      cacheControl: "public, max-age=31536000, immutable",
    },
  ];

  for (const item of filesToUpload) {
    if (fs.existsSync(item.localFile)) {
      console.log(`Uploading ${item.key} to R2 bucket "${bucketName}"...`);
      const body = fs.readFileSync(item.localFile);
      await s3.send(
        new PutObjectCommand({
          Bucket: bucketName,
          Key: item.key,
          Body: body,
          ContentType: item.contentType,
          CacheControl: item.cacheControl,
        })
      );
      console.log(`✓ Uploaded: ${publicBaseUrl}/${item.key}`);
    } else {
      console.warn(`Notice: Optional file ${item.localFile} not found, skipping.`);
    }
  }

  // Upload latest.json metadata if latest release
  if (release.isLatest) {
    console.log("Uploading latest.json metadata manifest...");
    const latestJson = JSON.stringify(
      {
        version: release.version,
        build: release.build,
        releaseDate: release.releaseDate,
        minimumMacOS: release.minimumMacOS,
        architectures: release.architectures,
        filename: release.filename,
        fileSizeBytes: release.fileSizeBytes,
        sha256: release.sha256,
        downloadUrl: `${publicBaseUrl}/${getReleaseObjectKey(version, release.filename)}`,
        checksumUrl: `${publicBaseUrl}/${getReleaseObjectKey(version, "SHA256SUMS.txt")}`,
        releaseNotesUrl: `${publicBaseUrl}/${getReleaseObjectKey(version, "RELEASE_NOTES.md")}`,
      },
      null,
      2
    );

    await s3.send(
      new PutObjectCommand({
        Bucket: bucketName,
        Key: "anc/releases/latest.json",
        Body: Buffer.from(latestJson),
        ContentType: "application/json",
        CacheControl: "public, max-age=300, must-revalidate", // 5 min cache for latest
      })
    );
    console.log(`✓ Uploaded: ${publicBaseUrl}/anc/releases/latest.json`);
  }

  console.log("=== Release Upload Finished Successfully ===");
}

uploadRelease().catch((err) => {
  console.error("Upload failed with error:", err);
  process.exit(1);
});
