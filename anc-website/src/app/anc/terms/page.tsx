import React from "react";
import type { Metadata } from "next";
import { FileText, ShieldAlert, Scale, AlertCircle } from "lucide-react";

export const metadata: Metadata = {
  title: "Terms and Conditions",
  description:
    "Terms and Conditions governing the download, installation, and usage of ARRY Network Counter (ANC) on macOS.",
};

export default function TermsPage() {
  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-12">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <Scale className="w-3.5 h-3.5 text-neutral-400" />
            <span>SOFTWARE LICENSE AGREEMENT</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Terms and Conditions
          </h1>
          <p className="text-xs sm:text-sm text-neutral-400">
            Effective Date: January 1, 2026 · Product: ARRY Network Counter (ANC) · Brand & Provider: ARRRY
          </p>
        </div>

        {/* Terms Sections */}
        <div className="space-y-8 text-xs sm:text-sm text-neutral-300 leading-relaxed">
          {/* 1. Acceptance */}
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] space-y-2">
            <h3 className="text-base font-bold text-white">1. Acceptance of Terms</h3>
            <p>
              By downloading, installing, copying, accessing, or using the <strong>ARRY Network Counter</strong> software application (&quot;ANC&quot; or the &quot;Application&quot;), you agree to be bound by these Terms and Conditions (&quot;Terms&quot;). If you do not agree to these Terms, do not install, copy, or use the Application.
            </p>
            <p className="text-neutral-400">
              These Terms constitute an agreement between you (the individual or entity using the software) and <strong>ARRRY</strong> (&quot;Developer&quot;, &quot;we&quot;, &quot;us&quot;, or &quot;our&quot;).
            </p>
          </div>

          {/* 2. Description and Intended Use */}
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] space-y-2">
            <h3 className="text-base font-bold text-white">2. Description and Intended Use</h3>
            <p>
              ARRY Network Counter is a lightweight, native macOS menu-bar utility developed to display real-time network throughput measurements based on macOS operating system statistics.
            </p>
            <p className="text-neutral-400">
              The Application is provided exclusively for personal, informational, and convenience purposes. It is <strong>not</strong> intended, certified, or designed for use in mission-critical environments, formal telecommunications auditing, billing dispute resolution, or commercial network quality certification.
            </p>
          </div>

          {/* 3. License and Permitted Use */}
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] space-y-2">
            <h3 className="text-base font-bold text-white">3. License and Permitted Use</h3>
            <p>
              Subject to these Terms, ARRRY grants you a personal, revocable, non-exclusive, non-transferable, royalty-free license to install and run executable copies of the Application on Apple-branded computers running compatible versions of macOS for lawful personal or internal evaluation purposes.
            </p>
            <p className="text-neutral-400">
              You agree not to sublicense, sell, lease, or rent the Application; reverse engineer or decompile the Application except to the extent permitted by applicable law; or remove copyright notices or legal attributions.
            </p>
          </div>

          {/* 4. Measurement Accuracy Limitations */}
          <div className="p-6 rounded-2xl bg-[#14120E] border border-amber-500/20 space-y-2">
            <h3 className="text-base font-bold text-amber-300">4. Measurement Accuracy Limitations</h3>
            <p>
              You expressly acknowledge that throughput calculations are derived from operating system kernel byte counters (<code className="font-mono text-amber-200">getifaddrs</code>) sampled over periodic monotonic intervals (~1 second).
            </p>
            <p className="text-neutral-400">
              Displayed throughput represents an approximate instantaneous average and does not reflect continuous physical wire speed or microsecond burst rates. Interface transitions, virtual network adapters (VPNs), and system scheduling jitter can introduce temporary measurement interruptions. Measurements encompass all traffic traversing the selected interface (both LAN and WAN). The Application must not be relied upon as an official benchmark for contractual internet speed guarantees or service provider level agreements (SLAs).
            </p>
          </div>

          {/* 5. No Warranty */}
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] space-y-2">
            <h3 className="text-base font-bold text-white">5. No Warranty / Guarantee</h3>
            <p className="text-neutral-400 font-mono text-xs uppercase leading-relaxed">
              TO THE MAXIMUM EXTENT PERMITTED UNDER APPLICABLE LAW, THE APPLICATION IS PROVIDED &quot;AS IS&quot; AND &quot;AS AVAILABLE&quot;, WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND. ARRRY DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, INCLUDING MERCHANTABILITY, SATISFACTORY QUALITY, AND FITNESS FOR A PARTICULAR PURPOSE.
            </p>
          </div>

          {/* 6. Limitation of Liability */}
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] space-y-2">
            <h3 className="text-base font-bold text-white">6. Limitation of Liability</h3>
            <p className="text-neutral-400 font-mono text-xs uppercase leading-relaxed">
              TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL ARRRY, ITS CONTRIBUTORS, OR ITS AFFILIATES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, CONSEQUENTIAL, OR PUNITIVE DAMAGES (INCLUDING LOSS OF DATA, REVENUE, HARDWARE DAMAGE, OR BUSINESS INTERRUPTION) ARISING OUT OF OR RELATED TO YOUR USE OF OR INABILITY TO USE THE APPLICATION.
            </p>
          </div>

          {/* 7. Third-Party Trademarks */}
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] space-y-2">
            <h3 className="text-base font-bold text-white">7. Third-Party Technologies and Apple Dependencies</h3>
            <p className="text-neutral-400">
              Apple, macOS, Mac, Apple Silicon, and Finder are trademarks of Apple Inc., registered in the U.S. and other countries. ARRY Network Counter is an independent software project developed by ARRRY and is <strong>not</strong> endorsed, sponsored, affiliated with, or certified by Apple Inc.
            </p>
          </div>

          {/* 8. Notice on Verification & Identification */}
          <div className="p-6 rounded-2xl bg-amber-500/10 border border-amber-500/20 text-xs sm:text-sm text-amber-200/90 space-y-2">
            <div className="font-semibold text-amber-300 flex items-center gap-1.5">
              <AlertCircle className="w-4 h-4" />
              Notice on Legal Entity & Support Channels:
            </div>
            <p className="text-xs text-neutral-300 leading-relaxed">
              Specific legal jurisdiction, designated corporate registration, physical postal address, and dedicated commercial support channels require project owner confirmation and are intentionally omitted from this initial product release. For open-source inquiries, bug reports, and project contributions, please refer to the official ARRRY project repository.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
