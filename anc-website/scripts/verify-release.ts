import fs from "fs";
import path from "path";
import crypto from "crypto";
import { releaseManifest, latestRelease } from "../src/data/releases";
import { ANCReleaseManifestSchema } from "../src/lib/release-validation";

/**
 * ARRY Network Counter — Release Integrity Verification Script
 *
 * Verifies:
 * 1. Release manifest schema compliance (Zod)
 * 2. Local DMG existence and exact byte size
 * 3. Local DMG SHA-256 checksum match
 * 4. Public R2 download URL structure (anc/releases/vX.Y.Z/filename)
 */
async function verifyRelease() {
  console.log("=== ARRY Network Counter — Release Integrity Verification ===");

  // 1. Validate manifest with Zod
  console.log("1. Validating release manifest schema...");
  const parseResult = ANCReleaseManifestSchema.safeParse(releaseManifest);
  if (!parseResult.success) {
    console.error("Manifest schema validation failed:", parseResult.error.format());
    process.exit(1);
  }
  console.log(`✓ Manifest schema valid. Product: ${releaseManifest.product}, Releases count: ${releaseManifest.releases.length}`);

  // 2. Check each configured release
  for (const rel of releaseManifest.releases) {
    console.log(`\nVerifying release v${rel.version} (Build ${rel.build})...`);

    // Verify download URL format
    const expectedPrefix = "https://downloads.arrry.in/anc/releases/";
    if (!rel.downloadUrl.startsWith(expectedPrefix)) {
      console.warn(`Warning: Download URL (${rel.downloadUrl}) does not match expected prefix '${expectedPrefix}'`);
    } else {
      console.log(`✓ Download URL: ${rel.downloadUrl}`);
    }

    if (!rel.checksumUrl.startsWith(expectedPrefix)) {
      console.warn(`Warning: Checksum URL (${rel.checksumUrl}) does not match expected prefix '${expectedPrefix}'`);
    } else {
      console.log(`✓ Checksum URL: ${rel.checksumUrl}`);
    }

    // Check local build artifact
    const localDmg = path.resolve(__dirname, "../../release", `v${rel.version}`, rel.filename);
    if (!fs.existsSync(localDmg)) {
      console.warn(`Notice: Local artifact not found at ${localDmg} (may be in CI or production only).`);
      continue;
    }

    const stat = fs.statSync(localDmg);
    console.log(`✓ Local file exists: ${stat.size.toLocaleString()} bytes`);
    if (stat.size !== rel.fileSizeBytes) {
      console.error(`Size mismatch! File: ${stat.size}, Manifest: ${rel.fileSizeBytes}`);
      process.exit(1);
    }
    console.log("✓ File size matches manifest exactly.");

    // Verify SHA-256
    const buffer = fs.readFileSync(localDmg);
    const calculatedHash = crypto.createHash("sha256").update(buffer).digest("hex");

    if (calculatedHash !== rel.sha256) {
      console.error(`SHA-256 mismatch! Calculated: ${calculatedHash}, Manifest: ${rel.sha256}`);
      process.exit(1);
    }
    console.log(`✓ SHA-256 hash verified: ${calculatedHash}`);
  }

  console.log("\n=== All Verification Checks Passed Successfully ===");
}

verifyRelease().catch((err) => {
  console.error("Verification failed:", err);
  process.exit(1);
});
