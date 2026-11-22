# ARRY Network Counter — Website Deployment Guide

**Production Domain:** `anc.arrry.in` (or `/anc` under `arrry.in`)  
**Download Domain:** `downloads.arrry.in` (Cloudflare R2)  
**Framework:** Next.js (App Router) + TypeScript + Tailwind CSS  

---

## 1. Hosting Architecture

The ANC official website is designed for standard deployment on **Vercel** or any modern Node.js/Container hosting environment:

- **Frontend & Edge Routing:** Next.js App Router deployed to Vercel or cloud CDN.
- **Large Release Artifacts:** Stored on Cloudflare R2 and served from `downloads.arrry.in`.
- **Static Pages:** All marketing, documentation, legal, and FAQ routes are statically pre-rendered for maximum performance and zero server latency.
- **Route Aliasing:** Both root paths (`/download`, `/features`) and subpaths (`/anc/download`, `/anc/features`) are supported via Next.js routing and rewrites.

---

## 2. Deployment to Vercel

### Step 1: Connect Git Repository
1. In the Vercel Dashboard, click **Add New** $\rightarrow$ **Project**.
2. Select the repository containing ANC.
3. Configure **Root Directory**: `anc-website`.

### Step 2: Configure Environment Variables
Set the following environment variables in Vercel:

| Variable | Value | Description |
|---|---|---|
| `R2_ACCOUNT_ID` | `[Account ID]` | Cloudflare account identifier |
| `R2_ACCESS_KEY_ID` | `[Access Key]` | Scoped R2 access key |
| `R2_SECRET_ACCESS_KEY` | `[Secret Key]` | Scoped R2 secret key |
| `R2_BUCKET_NAME` | `arrry` | R2 bucket name |
| `R2_PUBLIC_BASE_URL` | `https://downloads.arrry.in` | Custom download domain |

### Step 3: Domain & DNS Configuration
In Vercel Project Settings $\rightarrow$ **Domains**:
1. Add `anc.arrry.in`.
2. Add the recommended CNAME record in your Cloudflare DNS zone for `arrry.in`:
   - Type: `CNAME`
   - Name: `anc`
   - Target: `cname.vercel-dns.com`
   - Proxy: `DNS only` (recommended) or `Proxied` (with Full SSL/TLS mode).

---

## 3. Production Health Checklist

Before marking deployment complete:

- [ ] `https://anc.arrry.in` loads the Landing Page with interactive playground.
- [ ] `https://anc.arrry.in/download` loads the Download Center.
- [ ] `https://anc.arrry.in/download/latest` redirects (307) directly to current DMG.
- [ ] `https://downloads.arrry.in/anc/releases/v1.0.0/ARRY-Network-Counter.dmg` returns HTTP 200 with correct file size (5,304,733 bytes).
- [ ] All legal routes (`/privacy`, `/terms`) are accessible.
- [ ] `/sitemap.xml` and `/robots.txt` return valid XML/text.
- [ ] Mobile navigation and responsive layouts function cleanly on mobile devices.
