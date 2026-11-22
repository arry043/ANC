import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { releasesData } from "@/data/releases";
import { History, Download, Calendar, Cpu, HardDrive, ShieldCheck, Tag } from "lucide-react";

export const metadata: Metadata = {
  title: "Release Notes & Changelog",
  description:
    "Official release history and changelog for ARRY Network Counter on macOS. Track new features, performance enhancements, and verified builds.",
};

export default function ChangelogPage() {
  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-emerald-500/10 blur-[140px] pointer-events-none rounded-full" />

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-16">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <History className="w-3.5 h-3.5 text-emerald-400" />
            <span>RELEASE HISTORY & MILESTONES</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Changelog
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Detailed release notes and build verification records for ARRY Network Counter.
          </p>
        </div>

        {/* Release Timeline */}
        <div className="space-y-12">
          {releasesData.map((release) => (
            <div
              key={release.version}
              className="p-8 sm:p-10 rounded-3xl bg-[#0F0F14]/90 backdrop-blur-xl border border-white/[0.08] shadow-xl space-y-8 relative"
            >
              {/* Release Header */}
              <div className="flex flex-wrap items-center justify-between gap-4 pb-6 border-b border-white/[0.08]">
                <div className="space-y-1">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl sm:text-3xl font-extrabold text-white">
                      v{release.version}
                    </span>
                    <span className="px-3 py-1 rounded-full text-xs font-semibold text-emerald-400 bg-emerald-500/10 border border-emerald-500/30">
                      {release.isLatest ? "Current Release" : "Archived"}
                    </span>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-neutral-400 font-mono">
                    <span className="flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      {release.releaseDate}
                    </span>
                    <span>•</span>
                    <span>Build {release.build}</span>
                  </div>
                </div>

                <a
                  href={release.downloadUrl}
                  download={release.filename}
                  className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-500 shadow-md transition-all"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>Download DMG ({release.formattedSize})</span>
                </a>
              </div>

              {/* Specs Pills */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs font-mono">
                <div className="p-3 bg-black/40 rounded-xl border border-white/5 space-y-1">
                  <div className="text-[10px] text-neutral-500">PACKAGE</div>
                  <div className="text-white truncate">{release.filename}</div>
                </div>
                <div className="p-3 bg-black/40 rounded-xl border border-white/5 space-y-1">
                  <div className="text-[10px] text-neutral-500">SIZE</div>
                  <div className="text-emerald-400">{release.formattedSize}</div>
                </div>
                <div className="p-3 bg-black/40 rounded-xl border border-white/5 space-y-1">
                  <div className="text-[10px] text-neutral-500">ARCHITECTURES</div>
                  <div className="text-white">arm64 + x86_64</div>
                </div>
                <div className="p-3 bg-black/40 rounded-xl border border-white/5 space-y-1">
                  <div className="text-[10px] text-neutral-500">MINIMUM OS</div>
                  <div className="text-white">macOS {release.minimumMacOS}</div>
                </div>
              </div>

              {/* What's New Highlights */}
              <div className="space-y-4">
                <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
                  <Tag className="w-4 h-4 text-emerald-400" />
                  What&apos;s New in v{release.version}
                </h3>
                <ul className="space-y-2.5 text-xs sm:text-sm text-neutral-300">
                  {release.highlights.map((h, idx) => (
                    <li key={idx} className="flex items-start gap-2.5">
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-2 shrink-0" />
                      <span className="leading-relaxed">{h}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Checksum Box */}
              <div className="p-4 rounded-xl bg-black/60 border border-white/5 space-y-1 text-xs">
                <div className="text-neutral-400 flex items-center justify-between">
                  <span className="font-semibold text-neutral-300">SHA-256 Checksum</span>
                  <span className="font-mono text-[10px] text-neutral-500">R2 Verified</span>
                </div>
                <div className="font-mono text-emerald-400 text-[11px] break-all select-all pt-1">
                  {release.sha256}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
