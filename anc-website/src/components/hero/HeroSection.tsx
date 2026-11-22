"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";
import { Download, Sparkles, Shield, Cpu, Gauge, Terminal } from "lucide-react";
import { ANCPlayground } from "./ANCPlayground";
import { latestRelease } from "@/data/releases";

export function HeroSection() {
  return (
    <section className="relative pt-28 pb-16 lg:pt-36 lg:pb-24 overflow-hidden">
      {/* Background radial gradients & subtle Apple ambient lighting */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[550px] bg-gradient-to-b from-emerald-500/10 via-sky-500/5 to-transparent blur-[140px] pointer-events-none rounded-full" />
      <div className="absolute top-1/3 left-10 w-72 h-72 bg-emerald-500/5 blur-3xl pointer-events-none rounded-full" />
      <div className="absolute top-1/4 right-10 w-72 h-72 bg-blue-500/5 blur-3xl pointer-events-none rounded-full" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Main Hero Header */}
        <div className="text-center max-w-3xl mx-auto space-y-6">
          {/* Release Version Pill */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs text-neutral-300 backdrop-blur-md shadow-sm">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span className="font-medium">Version {latestRelease.version} is now available</span>
            <span className="text-neutral-500">•</span>
            <span className="text-xs text-neutral-400">Requires macOS Ventura or later</span>
          </div>

          {/* Editorial Headline */}
          <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight text-white leading-[1.08]">
            Your Network. <br />
            <span className="bg-gradient-to-r from-emerald-400 via-teal-300 to-sky-400 bg-clip-text text-transparent">
              At a Glance.
            </span>
          </h1>

          {/* Subtitle */}
          <p className="text-base sm:text-lg text-neutral-400 max-w-2xl mx-auto leading-relaxed">
            Monitor your real-time download and upload speeds directly from your macOS menu bar.
            Lightweight, native, and always within reach.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-2">
            <a
              href={latestRelease.downloadUrl}
              download={latestRelease.filename}
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-7 py-3.5 rounded-2xl text-sm font-semibold text-white bg-gradient-to-b from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 shadow-[0_4px_20px_rgba(48,184,107,0.4),inset_0_1px_0_0_rgba(255,255,255,0.25)] active:scale-95 transition-all duration-200"
            >
              <Download className="w-4 h-4" />
              <span>Download for macOS ({latestRelease.formattedSize})</span>
            </a>

            <Link
              href="/anc/download"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-2xl text-sm font-medium text-neutral-300 hover:text-white bg-white/[0.04] hover:bg-white/[0.08] border border-white/[0.08] transition-all duration-200"
            >
              <span>Download Center</span>
            </Link>
          </div>

          {/* Technical Trust Badges */}
          <div className="flex flex-wrap items-center justify-center gap-6 pt-4 text-xs text-neutral-400">
            <div className="flex items-center gap-2">
              <Cpu className="w-4 h-4 text-emerald-400" />
              <span>Apple Silicon & Intel Macs</span>
            </div>
            <div className="flex items-center gap-2">
              <Gauge className="w-4 h-4 text-sky-400" />
              <span>Lightweight · Minimal CPU</span>
            </div>
            <div className="flex items-center gap-2">
              <Shield className="w-4 h-4 text-teal-400" />
              <span>100% Private · Zero Tracking</span>
            </div>
          </div>
        </div>

        {/* INTERACTIVE PLAYGROUND (Connected Two Panels) */}
        <div className="mt-16 lg:mt-24">
          <ANCPlayground />
        </div>
      </div>
    </section>
  );
}
