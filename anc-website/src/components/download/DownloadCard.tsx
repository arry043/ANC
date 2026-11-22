"use client";

import React, { useState } from "react";
import Link from "next/link";
import { Download, Copy, Check, ShieldCheck, Cpu, HardDrive, Terminal, FileText, ArrowRight, ExternalLink } from "lucide-react";
import { ANCRelease } from "@/types/release";

interface DownloadCardProps {
  release: ANCRelease;
  isLatest?: boolean;
}

export function DownloadCard({ release, isLatest = true }: DownloadCardProps) {
  const [copiedSha, setCopiedSha] = useState(false);

  const copyChecksum = () => {
    navigator.clipboard.writeText(release.sha256);
    setCopiedSha(true);
    setTimeout(() => setCopiedSha(false), 2000);
  };

  return (
    <div className="relative rounded-3xl bg-[#111116]/90 backdrop-blur-2xl border border-white/[0.12] shadow-[0_25px_60px_rgba(0,0,0,0.7),inset_0_1px_0_0_rgba(255,255,255,0.15)] p-6 sm:p-8 lg:p-10 overflow-hidden">
      {/* Decorative ambient glow */}
      <div className="absolute top-0 right-0 w-80 h-80 bg-emerald-500/10 blur-[100px] pointer-events-none rounded-full" />

      <div className="relative z-10 space-y-8">
        {/* Header Badges & Version */}
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <span className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
              v{release.version}
            </span>
            {isLatest && (
              <span className="px-3 py-1 rounded-full text-xs font-semibold text-emerald-400 bg-emerald-500/10 border border-emerald-500/30">
                Latest General Release
              </span>
            )}
            <span className="text-xs text-neutral-400 font-mono">
              Build {release.build}
            </span>
          </div>

          <div className="text-xs text-neutral-400 font-mono">
            Released: {release.releaseDate}
          </div>
        </div>

        {/* Technical Specs Pills Grid */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div className="p-3.5 rounded-xl bg-white/[0.03] border border-white/[0.06] space-y-1">
            <div className="text-[11px] text-neutral-400 flex items-center gap-1.5">
              <Cpu className="w-3.5 h-3.5 text-emerald-400" />
              <span>Architectures</span>
            </div>
            <div className="text-xs font-semibold text-white font-mono">
              arm64 + x86_64
            </div>
          </div>

          <div className="p-3.5 rounded-xl bg-white/[0.03] border border-white/[0.06] space-y-1">
            <div className="text-[11px] text-neutral-400 flex items-center gap-1.5">
              <HardDrive className="w-3.5 h-3.5 text-sky-400" />
              <span>DMG Size</span>
            </div>
            <div className="text-xs font-semibold text-white font-mono">
              {release.formattedSize}
            </div>
          </div>

          <div className="p-3.5 rounded-xl bg-white/[0.03] border border-white/[0.06] space-y-1">
            <div className="text-[11px] text-neutral-400 flex items-center gap-1.5">
              <ShieldCheck className="w-3.5 h-3.5 text-teal-400" />
              <span>Minimum OS</span>
            </div>
            <div className="text-xs font-semibold text-white font-mono">
              macOS {release.minimumMacOS}
            </div>
          </div>

          <div className="p-3.5 rounded-xl bg-white/[0.03] border border-white/[0.06] space-y-1">
            <div className="text-[11px] text-neutral-400 flex items-center gap-1.5">
              <Terminal className="w-3.5 h-3.5 text-amber-400" />
              <span>Signing Status</span>
            </div>
            <div className="text-xs font-semibold text-amber-300 font-mono">
              Ad-hoc (Gatekeeper verified)
            </div>
          </div>
        </div>

        {/* Primary Download CTA Button */}
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
          <a
            href={release.downloadUrl}
            download={release.filename}
            className="flex-1 inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl text-base font-semibold text-white bg-gradient-to-b from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 shadow-[0_4px_25px_rgba(48,184,107,0.45),inset_0_1px_0_0_rgba(255,255,255,0.25)] active:scale-98 transition-all"
          >
            <Download className="w-5 h-5" />
            <span>Download {release.filename} ({release.formattedSize})</span>
          </a>

          <Link
            href="/anc/install"
            className="inline-flex items-center justify-center gap-2 px-6 py-4 rounded-2xl text-sm font-medium text-neutral-300 hover:text-white bg-white/[0.04] hover:bg-white/[0.08] border border-white/[0.08] transition-all"
          >
            <span>Installation Guide</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>

        {/* SHA-256 Checksum Card with Direct Artifact Links */}
        <div className="p-4 rounded-2xl bg-black/60 border border-white/[0.08] space-y-3">
          <div className="flex items-center justify-between text-xs text-neutral-400">
            <span className="flex items-center gap-1.5 font-medium">
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
              SHA-256 Checksum (Cloudflare R2 Delivery)
            </span>
            <button
              onClick={copyChecksum}
              className="inline-flex items-center gap-1 text-[11px] text-emerald-400 hover:text-emerald-300 transition-colors"
            >
              {copiedSha ? (
                <>
                  <Check className="w-3.5 h-3.5" />
                  <span>Copied to Clipboard</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Checksum</span>
                </>
              )}
            </button>
          </div>

          <div className="font-mono text-xs text-neutral-300 break-all select-all bg-white/[0.02] p-2.5 rounded-xl border border-white/5">
            {release.sha256}
          </div>

          <div className="flex flex-wrap items-center justify-between gap-2 pt-1 text-[11px] text-neutral-400 border-t border-white/5">
            <div>
              Terminal check: <code className="text-neutral-300 font-mono">shasum -a 256 {release.filename}</code>
            </div>

            <div className="flex items-center gap-4">
              <a
                href={release.checksumUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-emerald-400 hover:text-emerald-300 transition-colors inline-flex items-center gap-1"
              >
                <span>SHA256SUMS.txt</span>
                <ExternalLink className="w-3 h-3" />
              </a>

              {release.releaseNotesUrl && (
                <a
                  href={release.releaseNotesUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sky-400 hover:text-sky-300 transition-colors inline-flex items-center gap-1"
                >
                  <span>RELEASE_NOTES.md</span>
                  <ExternalLink className="w-3 h-3" />
                </a>
              )}
            </div>
          </div>
        </div>

        {/* Highlights & Release Notes */}
        <div className="space-y-3 pt-2">
          <h4 className="text-xs font-semibold text-neutral-300 uppercase tracking-wider flex items-center gap-2">
            <FileText className="w-3.5 h-3.5 text-emerald-400" />
            Release Highlights
          </h4>
          <ul className="grid grid-cols-1 md:grid-cols-2 gap-2 text-xs text-neutral-400">
            {release.highlights.map((item, idx) => (
              <li key={idx} className="flex items-start gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
                <span className="leading-relaxed">{item}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}
