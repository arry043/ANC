# Cloudflare R2 Storage Architecture & Setup Guide

**Product:** ARRY Network Counter (ANC)  
**Bucket Name:** `arrry`  
**Custom Download Domain:** `downloads.arrry.in`  
**Primary Artifact:** `ARRY-Network-Counter.dmg`  

---

## 1. Overview

ARRY Network Counter distributes universal macOS disk images (`.dmg`) using Cloudflare R2 object storage. This architecture delivers:

- **Direct Edge Delivery:** Fast global downloads via Cloudflare's CDN without hitting Next.js server resources.
- **Zero Egress Fees:** Cloudflare R2 charges $0 for outbound bandwidth egress.
- **Immutable Releases:** Versioned directory paths prevent accidental overwrite of published releases.
- **Strict Separation of Concerns:** Secret API credentials reside exclusively on secure build servers and deployment scripts; zero credentials are leaked to the client bundle.

---

## 2. Bucket Object Hierarchy

Release artifacts are organized in the bucket following this deterministic structure:

```text
arrry/
│
└── anc/
    └── releases/
        ├── v1.0.0/
        │   ├── ARRY-Network-Counter.dmg     (5.3 MB Universal Binary DMG)
        │   ├── SHA256SUMS.txt               (Cryptographic verification manifest)
        │   └── RELEASE_NOTES.md             (Version release documentation)
        │
        └── v1.0.1/                          (Future releases follow identical naming)
            ├── ARRY-Network-Counter.dmg
            ├── SHA256SUMS.txt
            └── RELEASE_NOTES.md
```

---

## 3. Provisioning the R2 Bucket

### Step 1: Create the Bucket
1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. In the left navigation, select **R2** $\rightarrow$ **Overview**.
3. Click **Create bucket**.
4. Name the bucket: `arrry`.
5. Select **Automatic** location or pick your preferred primary region.
6. Click **Create Bucket**.

### Step 2: Configure Custom Domain
Connecting a custom domain enables clean branding and high-speed delivery at `downloads.arrry.in`:

1. In the `arrry` bucket view, click the **Settings** tab.
2. Under **Public Access**, find **Custom Domains** and click **Connect Domain**.
3. Enter `downloads.arrry.in`.
4. Cloudflare will automatically configure the CNAME record in your `arrry.in` DNS zone.
5. Click **Connect Domain**.
6. SSL/TLS certificates will be automatically provisioned within 1–5 minutes.

### Step 3: Configure Cache Headers & CORS
In the bucket **Settings** tab:

1. **CORS Policy (Cross-Origin Resource Sharing):**
   ```json
   [
     {
       "AllowedOrigins": [
         "https://anc.arrry.in",
         "https://arrry.in"
       ],
       "AllowedMethods": ["GET", "HEAD"],
       "AllowedHeaders": ["*"],
       "MaxAgeSeconds": 86400
     }
   ]
   ```

2. **Cache Headers for Versioned Artifacts:**
   - Versioned releases (`/anc/releases/v*/*`) are immutable. Set:
     `Cache-Control: public, max-age=31536000, immutable`

---

## 4. Generating Scoped API Tokens

Never use account global API keys. Create a narrowly-scoped API token for release uploads:

1. In the Cloudflare Dashboard, go to **R2** $\rightarrow$ **Manage R2 API Tokens**.
2. Click **Create API Token**.
3. Name: `arrry-release-uploader`.
4. Permissions: **Object Read & Write**.
5. Scope: Apply specifically to bucket `arrry`.
6. TTL: Optional expiry or standing token.
7. Click **Create API Token**.
8. Record the following credentials in your deployment environment:
   - `R2_ACCOUNT_ID`
   - `R2_ACCESS_KEY_ID`
   - `R2_SECRET_ACCESS_KEY`
   - `R2_S3_ENDPOINT`

---

## 5. Environment Variables Configuration

Copy `.env.example` to `.env.local` for local script execution:

```env
# Cloudflare R2 Configuration (Server-Side / CI Only)
R2_ACCOUNT_ID="your_cloudflare_account_id"
R2_ACCESS_KEY_ID="your_r2_access_key_id"
R2_SECRET_ACCESS_KEY="your_r2_secret_access_key"
R2_BUCKET_NAME="arrry"
R2_S3_ENDPOINT="https://your_cloudflare_account_id.r2.cloudflarestorage.com"
R2_PUBLIC_BASE_URL="https://downloads.arrry.in"
```

> [!WARNING]
> Never commit `.env` or `.env.local` files to Git. Never prefix these variables with `NEXT_PUBLIC_` as that would expose secret keys to client browser bundles.

---

## 6. Storage Cost & Pricing Reference

Cloudflare R2 provides cost-effective object storage with **$0 egress fees**.

As of 2026, Cloudflare R2 offers:
- **Free Tier:** 10 GB storage per month, 1,000,000 Class A operations (writes), 10,000,000 Class B operations (reads).
- **Storage Beyond Free Tier:** ~$0.015 / GB-month.
- **Egress Fees:** $0.00 / GB (completely free outbound bandwidth).

Official pricing reference: [https://developers.cloudflare.com/r2/pricing/](https://developers.cloudflare.com/r2/pricing/)
