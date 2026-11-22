"use client";

import React from "react";
import Link from "next/link";
import { featuresList } from "@/data/features";
import { ArrowDown, ArrowUp, Activity, Cpu, ShieldCheck, Zap } from "lucide-react";

export function FeaturesShowcase() {
  return (
    <section className="py-24 bg-[#08080C] relative overflow-hidden border-t border-white/[0.06]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>ENGINEERED FOR MACOS</span>
          </div>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Carefully Crafted for Your Menu Bar
          </h2>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Every feature was designed to deliver immediate, non-intrusive clarity. No background telemetry, no battery drain, and no artificial overhead.
          </p>
        </div>

        {/* Feature Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {featuresList.map((feature) => (
            <div
              key={feature.id}
              className="p-6 rounded-2xl bg-[#111116]/80 backdrop-blur-xl border border-white/[0.08] hover:border-white/20 shadow-lg hover:shadow-[0_10px_30px_rgba(0,0,0,0.5)] transition-all duration-300 flex flex-col justify-between group"
            >
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-mono px-2.5 py-0.5 rounded-full bg-white/[0.05] border border-white/10 text-neutral-400">
                    {feature.badge}
                  </span>
                </div>

                <div>
                  <h3 className="text-base font-bold text-white group-hover:text-emerald-400 transition-colors">
                    {feature.title}
                  </h3>
                  <div className="text-xs text-neutral-500 font-medium mt-0.5">
                    {feature.subtitle}
                  </div>
                </div>

                <p className="text-xs text-neutral-400 leading-relaxed">
                  {feature.description}
                </p>

                {/* Specs List */}
                {feature.specs && (
                  <ul className="space-y-1.5 pt-2 border-t border-white/[0.06]">
                    {feature.specs.map((spec, idx) => (
                      <li key={idx} className="text-[11px] text-neutral-400 flex items-center gap-2">
                        <span className="w-1 h-1 rounded-full bg-emerald-400 shrink-0" />
                        <span>{spec}</span>
                      </li>
                    ))}
                  </ul>
                )}
              </div>

              {/* Visual Demo Card */}
              <div className="mt-6 p-3.5 bg-black/50 rounded-xl border border-white/[0.06] flex items-center justify-center font-mono text-xs">
                {feature.visualType === "both-separate" && (
                  <div className="flex items-center space-x-2">
                    <span className="text-[#30B86B] font-bold">↓ 2.45 MB/s</span>
                    <span className="w-2" />
                    <span className="text-[#3988E8] font-bold">↑ 120 KB/s</span>
                  </div>
                )}
                {feature.visualType === "both-combined" && (
                  <div className="flex items-center space-x-1.5">
                    <span className="text-[#30B86B] font-bold">↓</span>
                    <span className="text-[#3988E8] font-bold">↑</span>
                    <span className="text-white font-medium">2.45 MB/s</span>
                  </div>
                )}
                {feature.visualType === "both-text" && (
                  <div className="flex items-center space-x-2">
                    <span className="text-[#30B86B] font-bold">DL 2.45 MB/s</span>
                    <span className="w-2" />
                    <span className="text-[#3988E8] font-bold">UL 120 KB/s</span>
                  </div>
                )}
                {feature.visualType === "single-manual" && (
                  <div className="flex items-center space-x-1.5">
                    <span className="text-[#30B86B] font-bold">↓ 2.45 MB/s</span>
                    <span className="text-neutral-500 text-[10px]">(Pinned Download)</span>
                  </div>
                )}
                {feature.visualType === "single-auto" && (
                  <div className="flex items-center space-x-1.5">
                    <span className="text-[#30B86B] font-bold">↓ 2.45 MB/s</span>
                    <span className="text-neutral-500 text-[10px]">⇄ Auto Hysteresis</span>
                  </div>
                )}
                {feature.visualType === "specs-list" && (
                  <div className="flex items-center space-x-2 text-[11px] text-emerald-400">
                    <ShieldCheck className="w-4 h-4" />
                    <span>0.4% CPU · Zero Outbound Connections</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
