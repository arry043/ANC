# ARRY Network Counter (ANC) — Official Website

Official marketing, documentation, and release distribution platform for **ARRY Network Counter (ANC)**, a lightweight, native macOS menu-bar utility designed for real-time download and upload throughput monitoring.

## 🚀 Live Routes

- **Landing Page & Interactive Playground:** `/anc` and `/`
- **Download Center:** `/anc/download` and `/download`
- **Latest DMG Direct Redirect:** `/anc/download/latest`
- **Installation & Gatekeeper Guide:** `/anc/install` and `/install`
- **Product Features:** `/anc/features` and `/features`
- **User & Operations Guide:** `/anc/guide` and `/guide`
- **Changelog & Milestones:** `/anc/changelog` and `/changelog`
- **FAQ:** `/anc/faq` and `/faq`
- **Privacy Policy:** `/anc/privacy` and `/privacy`
- **Terms and Conditions:** `/anc/terms` and `/terms`

## 🛠 Tech Stack

- **Framework:** Next.js 16 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Icons:** Lucide React
- **Typography:** Geist & Geist Mono
- **Storage:** Cloudflare R2 (`downloads.arrry.in`)
- **Validation:** Zod

## 📦 Development & Verification

```bash
# Install dependencies
npm install

# Run integrity verification on release manifests
npx tsx scripts/verify-release.ts

# Start development server
npm run dev

# Run production build
npm run build
```

## 📚 Documentation

- [Cloudflare R2 Setup Guide](Documentation/R2_SETUP.md)
- [Release & Upload Workflow](Documentation/RELEASE_WORKFLOW.md)
- [Production Deployment Guide](Documentation/DEPLOYMENT.md)
