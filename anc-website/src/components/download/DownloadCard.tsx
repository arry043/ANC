"use client";

import React from "react";
import Link from "next/link";
import { Download, CheckCircle2, Shield, ArrowRight } from "lucide-react";
import { ANCRelease } from "@/types/release";

interface DownloadCardProps {
  release: ANCRelease;
  isLatest?: boolean;
}

export function DownloadCard({ release, isLatest = true }: DownloadCardProps) {
  return (
    <div className="relative rounded-3xl bg-[#111116]/90 backdrop-blur-2xl border border-white/[0.12] shadow-[0_25px_60px_rgba(0,0,0,0.7),inset_0_1px_0_0_rgba(255,255,255,0.15)] p-6 sm:p-8 lg:p-10 overflow-hidden">
      {/* Decorative ambient glow */}
      <div className="absolute top-0 right-0 w-80 h-80 bg-emerald-500/10 blur-[100px] pointer-events-none rounded-full" />

      <div className="relative z-10 space-y-8">
        {/* Header Badges & Version */}
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-3">
              <span className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
                ARRY Network Counter {release.version}
              </span>
              {isLatest && (
                <span className="px-3 py-1 rounded-full text-xs font-semibold text-emerald-400 bg-emerald-500/10 border border-emerald-500/30">
                  Latest Release
                </span>
              )}
            </div>
            <p className="text-xs text-neutral-400">
              Released on {release.releaseDate} · Requires macOS Ventura (13.0) or later
            </p>
          </div>

          <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs text-neutral-300">
            <Shield className="w-3.5 h-3.5 text-emerald-400" />
            <span>Apple Silicon & Intel Macs</span>
          </div>
        </div>

        {/* Short Summary & Key Highlights */}
        <div className="space-y-4">
          <p className="text-sm text-neutral-300 leading-relaxed">
            Initial general release of ARRY Network Counter for macOS.
          </p>

          <ul className="grid grid-cols-1 md:grid-cols-2 gap-2.5 text-xs text-neutral-300">
            {release.highlights.map((item, idx) => (
              <li key={idx} className="flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <span className="leading-relaxed">{item}</span>
              </li>
            ))}
          </ul>
        </div>

        {/* Download Actions */}
        <div className="pt-2 flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
          <a
            href={release.downloadUrl}
            download={release.filename}
            className="flex-1 inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-semibold text-white bg-gradient-to-b from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 shadow-[0_4px_25px_rgba(48,184,107,0.45),inset_0_1px_0_0_rgba(255,255,255,0.25)] active:scale-98 transition-all"
          >
            <Download className="w-5 h-5" />
            <span>Download for macOS ({release.formattedSize})</span>
          </a>

          <Link
            href="/anc/install"
            className="inline-flex items-center justify-center gap-2 px-6 py-4 rounded-2xl text-sm font-medium text-neutral-300 hover:text-white bg-white/[0.04] hover:bg-white/[0.08] border border-white/[0.08] transition-all"
          >
            <span>Installation Guide</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </div>
  );
}
