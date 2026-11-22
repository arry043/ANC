# ARRY Network Counter — Release & Upload Workflow

This document specifies the official, repeatable workflow for publishing a new version of ARRY Network Counter (ANC).

---

## 1. Release Lifecycle Steps

```text
[Build & Package DMG]
         │
         ▼
[Compute SHA-256 Checksum]
         │
         ▼
[Validate Release Manifest (Zod)]
         │
         ▼
[Upload Artifacts to Cloudflare R2]
         │
         ▼
[Verify Public Download URL & Headers]
         │
         ▼
[Deploy Website Updates]
```

---

## 2. Step-by-Step Instructions

### Step 1: Verify Completed Build & DMG
Ensure the universal DMG package has been built:
```bash
ls -lh release/v1.0.0/ARRY-Network-Counter.dmg
```

Verify Universal Binary architecture slices:
```bash
file "dist/ARRY Network Counter.app/Contents/MacOS/ARRY Network Counter"
```
Output must contain:
`Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64:Mach-O 64-bit executable arm64]`

### Step 2: Generate Checksum & Verification Manifest
Compute the SHA-256 hash:
```bash
shasum -a 256 release/v1.0.0/ARRY-Network-Counter.dmg
```
Store the result in `release/v1.0.0/SHA256SUMS.txt`.

### Step 3: Update Release Manifest
In `anc-website/src/data/releases.ts`, update `releasesData`:
```typescript
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
  highlights: [ ... ]
}
```

### Step 4: Run Verification Script
Validate the manifest and checksums:
```bash
cd anc-website
npx tsx scripts/verify-release.ts
```

### Step 5: Upload to Cloudflare R2
Upload the DMG and checksums using the automated upload script:
```bash
cd anc-website
npx tsx scripts/upload-release.ts 1.0.0
```

### Step 6: Verify Public Download Access
Confirm that the file is downloadable via curl:
```bash
curl -I https://downloads.arrry.in/anc/releases/v1.0.0/ARRY-Network-Counter.dmg
```
Verify:
- HTTP Status: `200 OK`
- `content-length`: matches manifest byte count (`5304733`)
- `cache-control`: `public, max-age=31536000, immutable`

### Step 7: Build & Test Website
Verify the website builds with zero errors:
```bash
cd anc-website
npm run build
```
