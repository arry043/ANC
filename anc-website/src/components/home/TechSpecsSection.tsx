import React from "react";
import { technicalSpecs } from "@/data/features";
import { Terminal, Cpu, Database, Check } from "lucide-react";

export function TechSpecsSection() {
  return (
    <section className="py-20 bg-[#060609] border-t border-white/[0.06]">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-12 space-y-3">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>SPECIFICATIONS & METRICS</span>
          </div>
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
            Technical Architecture
          </h2>
          <p className="text-xs sm:text-sm text-neutral-400">
            Data-driven specifications verifying every detail of ARRY Network Counter v1.0.0.
          </p>
        </div>

        {/* Specs Table */}
        <div className="rounded-2xl bg-[#0F0F14] border border-white/[0.08] overflow-hidden shadow-xl">
          <div className="divide-y divide-white/[0.06]">
            {technicalSpecs.map((spec, idx) => (
              <div
                key={idx}
                className="grid grid-cols-1 sm:grid-cols-3 px-6 py-3.5 text-xs hover:bg-white/[0.02] transition-colors"
              >
                <div className="font-medium text-neutral-400">
                  {spec.label}
                </div>
                <div className="sm:col-span-2 font-mono text-neutral-200 mt-0.5 sm:mt-0">
                  {spec.value}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
