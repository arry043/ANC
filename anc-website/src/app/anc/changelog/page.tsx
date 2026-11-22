import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { releasesData } from "@/data/releases";
import { History, Download, Calendar, Tag, CheckCircle2 } from "lucide-react";

export const metadata: Metadata = {
  title: "Release Notes & Changelog",
  description:
    "Official release history and changelog for ARRY Network Counter on macOS. Track new features and updates.",
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
            <span>RELEASE HISTORY</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Changelog
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Release notes and feature updates for ARRY Network Counter.
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
                  <div className="flex items-center gap-3 text-xs text-neutral-400">
                    <span className="flex items-center gap-1.5">
                      <Calendar className="w-3.5 h-3.5" />
                      {release.releaseDate}
                    </span>
                    <span>•</span>
                    <span>Requires macOS Ventura or later</span>
                  </div>
                </div>

                <a
                  href={release.downloadUrl}
                  download={release.filename}
                  className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-500 shadow-md transition-all"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>Download for macOS ({release.formattedSize})</span>
                </a>
              </div>

              {/* What's New Highlights */}
              <div className="space-y-4">
                <h3 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
                  <Tag className="w-4 h-4 text-emerald-400" />
                  What&apos;s New in v{release.version}
                </h3>
                <ul className="space-y-3 text-xs sm:text-sm text-neutral-300">
                  {release.highlights.map((h, idx) => (
                    <li key={idx} className="flex items-start gap-3">
                      <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                      <span className="leading-relaxed">{h}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
