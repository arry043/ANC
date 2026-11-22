import React from "react";
import Link from "next/link";
import { Download, ShieldCheck, Cpu } from "lucide-react";
import { latestRelease } from "@/data/releases";

export function FinalDownloadCTA() {
  return (
    <section className="py-24 bg-gradient-to-b from-[#08080C] to-[#040406] border-t border-white/[0.08] relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[350px] bg-emerald-500/10 blur-[130px] rounded-full pointer-events-none" />

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10 space-y-6">
        <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
          A clearer view of your network starts here.
        </h2>

        <p className="text-neutral-400 text-sm sm:text-base max-w-xl mx-auto leading-relaxed">
          Download ARRY Network Counter for macOS. Lightweight, native, and completely private.
        </p>

        <div className="pt-4 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href={latestRelease.downloadUrl}
            download={latestRelease.filename}
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-8 py-4 rounded-2xl text-sm font-semibold text-white bg-gradient-to-b from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 shadow-[0_4px_25px_rgba(48,184,107,0.45),inset_0_1px_0_0_rgba(255,255,255,0.25)] active:scale-95 transition-all duration-200"
          >
            <Download className="w-4 h-4" />
            <span>Download for macOS ({latestRelease.formattedSize})</span>
          </a>

          <Link
            href="/anc/install"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-4 rounded-2xl text-sm font-medium text-neutral-300 hover:text-white bg-white/[0.04] hover:bg-white/[0.08] border border-white/[0.08] transition-all"
          >
            <span>Installation Guide</span>
          </Link>
        </div>

        {/* Footnote */}
        <div className="pt-6 text-xs text-neutral-400">
          Requires macOS Ventura (13.0) or later · Compatible with Apple Silicon & Intel Macs
        </div>
      </div>
    </section>
  );
}
