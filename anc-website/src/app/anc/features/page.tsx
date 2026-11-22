import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { Download, ArrowDown, ArrowUp, Activity, Sliders, Shield, Zap, Sparkles } from "lucide-react";
import { featuresList } from "@/data/features";

export const metadata: Metadata = {
  title: "Product Features & Capabilities",
  description:
    "Explore the four native display modes, 3-factor hysteresis switching engine, SI decimal speed units, and privacy architecture of ARRY Network Counter.",
};

export default function FeaturesPage() {
  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      {/* Background radial glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-emerald-500/10 blur-[140px] pointer-events-none rounded-full" />

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-16">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>DETAILED FEATURE BREAKDOWN</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Product Capabilities
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Discover how ARRY Network Counter delivers precision network throughput monitoring while preserving your Mac&apos;s system resources and battery life.
          </p>
        </div>

        {/* Detailed Modes Sections */}
        <div className="space-y-12">
          {/* Mode 1: Both Directions */}
          <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-6">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span className="px-3 py-1 rounded-full text-xs font-mono bg-emerald-500/10 border border-emerald-500/30 text-emerald-400">
                Display Mode 1
              </span>
              <span className="text-xs text-neutral-500 font-mono">Default Configuration</span>
            </div>

            <div className="space-y-2">
              <h2 className="text-xl sm:text-2xl font-bold text-white">
                Both Directions — Three Presentation Styles
              </h2>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed">
                Tracks incoming download and outgoing upload bandwidth simultaneously. Choose from three visual styles tailored to your menu-bar space.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-2">
              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-2">
                <div className="text-xs font-semibold text-white">1. Separate Speeds</div>
                <div className="font-mono text-xs p-2.5 bg-white/[0.02] rounded-lg border border-white/5 flex items-center justify-center">
                  <span className="text-[#30B86B]">↓ 2.45 MB/s</span>
                  <span className="w-2" />
                  <span className="text-[#3988E8]">↑ 120 KB/s</span>
                </div>
                <p className="text-[11px] text-neutral-400">
                  Independent concurrent metrics with distinct green download and blue upload arrows.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-2">
                <div className="text-xs font-semibold text-white">2. Combined Arrows</div>
                <div className="font-mono text-xs p-2.5 bg-white/[0.02] rounded-lg border border-white/5 flex items-center justify-center">
                  <span className="text-[#30B86B]">↓</span>
                  <span className="text-[#3988E8] ml-1">↑</span>
                  <span className="text-white ml-2">2.45 MB/s</span>
                </div>
                <p className="text-[11px] text-neutral-400">
                  Dual arrows showing activity while highlighting only the speed of the dominant direction.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-2">
                <div className="text-xs font-semibold text-white">3. Without Arrows</div>
                <div className="font-mono text-xs p-2.5 bg-white/[0.02] rounded-lg border border-white/5 flex items-center justify-center">
                  <span className="text-[#30B86B] font-bold text-[11px]">DL 2.45 MB/s</span>
                  <span className="w-2" />
                  <span className="text-[#3988E8] font-bold text-[11px]">UL 120 KB/s</span>
                </div>
                <p className="text-[11px] text-neutral-400">
                  Letter abbreviations (DL/UL) with high-contrast styling for users preferring text.
                </p>
              </div>
            </div>
          </div>

          {/* Mode 2: Single Direction Manual */}
          <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-6">
            <span className="px-3 py-1 rounded-full text-xs font-mono bg-sky-500/10 border border-sky-500/30 text-sky-400">
              Display Mode 2
            </span>

            <div className="space-y-2">
              <h2 className="text-xl sm:text-2xl font-bold text-white">
                Single Direction — Manual
              </h2>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed">
                Pins the menu bar display strictly to your choice of Download or Upload. Your selection remains locked continuously regardless of traffic variations.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-2">
                <div className="text-xs font-semibold text-white">With Arrow Glyph</div>
                <div className="font-mono text-xs p-2.5 bg-white/[0.02] rounded-lg border border-white/5 flex items-center justify-center text-[#30B86B]">
                  ↓ 2.45 MB/s
                </div>
                <p className="text-[11px] text-neutral-400">
                  Direction arrow precedes the numerical throughput rate.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-2">
                <div className="text-xs font-semibold text-white">Without Arrow Glyph</div>
                <div className="font-mono text-xs p-2.5 bg-white/[0.02] rounded-lg border border-white/5 flex items-center justify-center text-white">
                  2.45 MB/s
                </div>
                <p className="text-[11px] text-neutral-400">
                  Clean numeric throughput representation without arrows.
                </p>
              </div>
            </div>
          </div>

          {/* Mode 3: Single Direction Automatic & Hysteresis */}
          <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-6">
            <span className="px-3 py-1 rounded-full text-xs font-mono bg-emerald-500/10 border border-emerald-500/30 text-emerald-400">
              Display Mode 3 · Intelligent Engine
            </span>

            <div className="space-y-2">
              <h2 className="text-xl sm:text-2xl font-bold text-white">
                Single Direction — Automatic with 3-Factor Hysteresis
              </h2>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed">
                Dynamically displays the direction currently carrying the higher traffic rate. To eliminate rapid, distracting visual flickering in the menu bar during balanced connections, ANC enforces a deterministic 3-factor hysteresis engine.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-1.5">
                <div className="text-xs font-semibold text-emerald-400 font-mono">10% Relative Margin</div>
                <p className="text-[11px] text-neutral-400">
                  Opposing direction must exceed active rate by at least 10%.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-1.5">
                <div className="text-xs font-semibold text-emerald-400 font-mono">10 KB/s Noise Floor</div>
                <p className="text-[11px] text-neutral-400">
                  Absolute speed difference must exceed 10,000 bytes per second.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-1.5">
                <div className="text-xs font-semibold text-emerald-400 font-mono">2 Consecutive Samples</div>
                <p className="text-[11px] text-neutral-400">
                  Qualifying dominance must persist across two 1-second sample intervals.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/40 border border-white/[0.06] space-y-1.5">
                <div className="text-xs font-semibold text-emerald-400 font-mono">Flapping Protection</div>
                <p className="text-[11px] text-neutral-400">
                  Temporary spikes immediately discard pending candidate states.
                </p>
              </div>
            </div>
          </div>

          {/* SI Decimal Units & Standards */}
          <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-6">
            <span className="px-3 py-1 rounded-full text-xs font-mono bg-teal-500/10 border border-teal-500/30 text-teal-400">
              Measurement Architecture
            </span>

            <div className="space-y-2">
              <h2 className="text-xl sm:text-2xl font-bold text-white">
                Standard SI Decimal Speed Formatting
              </h2>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed">
                Following standard macOS system conventions (ADR-014), ARRY Network Counter scales byte throughput using base-1000 decimal units:
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs font-mono">
              <div className="p-4 rounded-xl bg-black/40 border border-white/5 space-y-1">
                <div className="text-neutral-400">1 KB/s</div>
                <div className="text-white font-bold">1,000 B/s</div>
              </div>
              <div className="p-4 rounded-xl bg-black/40 border border-white/5 space-y-1">
                <div className="text-neutral-400">1 MB/s</div>
                <div className="text-white font-bold">1,000,000 B/s</div>
              </div>
              <div className="p-4 rounded-xl bg-black/40 border border-white/5 space-y-1">
                <div className="text-neutral-400">1 GB/s</div>
                <div className="text-white font-bold">1,000,000,000 B/s</div>
              </div>
            </div>

            <p className="text-xs text-neutral-400 leading-relaxed">
              Speeds are displayed in Bytes per second with up to 2 decimal places and trailing zero trimming (e.g. 1.5 MB/s instead of 1.50 MB/s). Idle network state is formatted cleanly as <strong>0 KB/s</strong>.
            </p>
          </div>
        </div>

        {/* CTA */}
        <div className="p-8 rounded-3xl bg-gradient-to-r from-emerald-500/10 via-teal-500/5 to-transparent border border-emerald-500/20 flex flex-col sm:flex-row items-center justify-between gap-6">
          <div className="space-y-1 text-center sm:text-left">
            <h3 className="text-lg font-bold text-white">Ready to experience ANC?</h3>
            <p className="text-xs text-neutral-400">Download the native macOS DMG package directly.</p>
          </div>
          <Link
            href="/anc/download"
            className="px-6 py-3 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-500 shadow-md transition-all shrink-0"
          >
            Download v1.0.0
          </Link>
        </div>
      </div>
    </div>
  );
}
