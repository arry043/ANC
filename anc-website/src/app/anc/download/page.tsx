import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { DownloadCard } from "@/components/download/DownloadCard";
import { latestRelease, previousReleases } from "@/data/releases";
import { Shield, Cloud, Terminal, CheckCircle2, History, AlertCircle } from "lucide-react";

export const metadata: Metadata = {
  title: "Download ARRY Network Counter",
  description:
    "Download the latest release of ARRY Network Counter (ANC) for macOS. Universal Binary for Apple Silicon and Intel with direct Cloudflare R2 distribution.",
};

export default function DownloadPage() {
  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      {/* Background radial glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-emerald-500/10 blur-[140px] pointer-events-none rounded-full" />

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-16">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>OFFICIAL DISTRIBUTION PLATFORM</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Download Center
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Download official, verified releases of ARRY Network Counter for macOS. Hosted with immutable versioning on Cloudflare R2.
          </p>
        </div>

        {/* Latest Release Card */}
        <div>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-sm font-semibold text-neutral-300 uppercase tracking-wider flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-emerald-400" />
              Latest Production Release
            </h2>
            <span className="text-xs text-neutral-500 font-mono">
              Stable Channel
            </span>
          </div>

          <DownloadCard release={latestRelease} isLatest={true} />
        </div>

        {/* Verification & Storage Information Card */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="p-6 rounded-2xl bg-[#0E0E14] border border-white/[0.08] space-y-3">
            <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 flex items-center justify-center">
              <Terminal className="w-4 h-4" />
            </div>
            <h3 className="text-sm font-semibold text-white">
              Local Checksum Verification
            </h3>
            <p className="text-xs text-neutral-400 leading-relaxed">
              Verify the integrity of your downloaded DMG using standard macOS Terminal utilities:
            </p>
            <div className="p-3 bg-black/60 rounded-xl border border-white/5 font-mono text-[11px] text-emerald-400 select-all">
              shasum -a 256 ~/Downloads/ARRY-Network-Counter.dmg
            </div>
            <p className="text-[11px] text-neutral-500">
              The output must match the SHA-256 hash displayed in the release card above.
            </p>
          </div>

          <div className="p-6 rounded-2xl bg-[#0E0E14] border border-white/[0.08] space-y-3">
            <div className="w-9 h-9 rounded-xl bg-sky-500/10 border border-sky-500/20 text-sky-400 flex items-center justify-center">
              <Cloud className="w-4 h-4" />
            </div>
            <h3 className="text-sm font-semibold text-white">
              Cloudflare R2 Distribution
            </h3>
            <p className="text-xs text-neutral-400 leading-relaxed">
              DMG packages are delivered directly from our high-speed object storage at <code className="text-sky-300 font-mono">downloads.arrry.in</code> with edge caching and zero tracking.
            </p>
            <div className="pt-1 flex items-center gap-2 text-xs text-neutral-400">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
              <span>Immutable object storage with direct HTTPS download</span>
            </div>
          </div>
        </div>

        {/* Previous Versions Section */}
        <div className="pt-8 border-t border-white/[0.08] space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-neutral-300 uppercase tracking-wider flex items-center gap-2">
              <History className="w-4 h-4 text-neutral-400" />
              Previous Releases
            </h2>
            <span className="text-xs text-neutral-500 font-mono">
              Version Archive
            </span>
          </div>

          {previousReleases.length === 0 ? (
            <div className="p-8 rounded-2xl bg-white/[0.02] border border-white/[0.06] text-center space-y-3">
              <div className="w-10 h-10 mx-auto rounded-full bg-white/[0.04] flex items-center justify-center text-neutral-400">
                <History className="w-5 h-5" />
              </div>
              <h3 className="text-sm font-medium text-white">
                v1.0.0 is the Initial General Release
              </h3>
              <p className="text-xs text-neutral-400 max-w-md mx-auto leading-relaxed">
                No older versions exist. When future updates (e.g., v1.0.1) are published to the release manifest, previous builds will automatically remain downloadable here with their respective checksums.
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              {previousReleases.map((rel) => (
                <DownloadCard key={rel.version} release={rel} isLatest={false} />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
