import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { DownloadCard } from "@/components/download/DownloadCard";
import { latestRelease, previousReleases } from "@/data/releases";
import { History } from "lucide-react";

export const metadata: Metadata = {
  title: "Download ARRY Network Counter",
  description:
    "Download the latest release of ARRY Network Counter (ANC) for macOS. Requires macOS Ventura or later.",
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
            <span>OFFICIAL DOWNLOADS</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Download Center
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Download the latest official release of ARRY Network Counter for macOS.
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
                No older versions exist. When future updates are published, previous builds will automatically remain downloadable here.
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
