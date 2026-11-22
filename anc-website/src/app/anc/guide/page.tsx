import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { BookOpen, Activity, AlertCircle, Shield, SlidersHorizontal, Terminal, CheckCircle2 } from "lucide-react";

export const metadata: Metadata = {
  title: "User & Operations Guide",
  description:
    "Comprehensive documentation on how ARRY Network Counter monitors network throughput, measurement scope, SI units, and limitations.",
};

export default function GuidePage() {
  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-16">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>OFFICIAL DOCUMENTATION</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            User & Operations Guide
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Detailed technical guide to measurement methodology, kernel counters, menu-bar display configurations, and operational scope.
          </p>
        </div>

        {/* Section 1: Introduction & How It Works */}
        <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-4">
          <h2 className="text-xl font-bold text-white flex items-center gap-2.5">
            <Activity className="w-5 h-5 text-emerald-400" />
            1. How It Works
          </h2>
          <p className="text-xs sm:text-sm text-neutral-300 leading-relaxed">
            ARRY Network Counter measures real-time download and upload activity by reading standard network interface metrics provided by macOS, calculating the exact bytes moving across your active connection each second.
          </p>
          <div className="space-y-2 pt-2 text-xs text-neutral-400">
            <div className="flex items-start gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
              <span><strong>Real-Time Sampling:</strong> Throughput is measured at smooth 1-second intervals for immediate, live feedback.</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
              <span><strong>Active Connection Focus:</strong> Traffic is monitored on your Mac&apos;s primary active connection (such as Wi-Fi or Ethernet).</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
              <span><strong>Lightweight & Non-Intrusive:</strong> Calculations run efficiently in memory without battery drain or slowdown.</span>
            </div>
          </div>
        </div>

        {/* Section 2: Important Measurement Scope Disclosures */}
        <div className="p-8 rounded-3xl bg-[#14120E] border border-amber-500/20 space-y-4">
          <h2 className="text-xl font-bold text-amber-300 flex items-center gap-2.5">
            <AlertCircle className="w-5 h-5 text-amber-400" />
            2. Scope & Limitations: What ANC Is Not
          </h2>
          <div className="space-y-3 text-xs sm:text-sm text-neutral-300 leading-relaxed">
            <p>
              To maintain absolute transparency with our users, please review the following operational boundaries:
            </p>
            <ul className="space-y-2 pl-2">
              <li className="flex items-start gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400 mt-1.5 shrink-0" />
                <span><strong>Not an Internet Speed Test:</strong> ANC measures actual data moving across your network interface. It does not ping speed-test servers, execute synthetic download tests, or consume your internet bandwidth.</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400 mt-1.5 shrink-0" />
                <span><strong>Local Network Traffic Included:</strong> Because kernel interface counters measure all link-level data traversing the hardware interface, local transfers (AirDrop, local NAS file copies, Time Machine network backups, printer data) and external internet traffic both contribute to throughput.</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400 mt-1.5 shrink-0" />
                <span><strong>Not a Quota/Billing Tracker:</strong> ANC does not store historical traffic logs or track monthly ISP data caps. All throughput metrics exist only in volatile RAM for instantaneous display.</span>
              </li>
            </ul>
          </div>
        </div>

        {/* Section 3: Settings & Customization */}
        <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-4">
          <h2 className="text-xl font-bold text-white flex items-center gap-2.5">
            <SlidersHorizontal className="w-5 h-5 text-emerald-400" />
            3. Configuring Settings
          </h2>
          <p className="text-xs sm:text-sm text-neutral-300 leading-relaxed">
            Click the ARRY Network Counter status item in your macOS menu bar and select <strong>Settings…</strong> (or press <strong>⌘,</strong>) to open the native settings window:
          </p>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-2 text-xs">
            <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
              <div className="font-semibold text-white">Preferences Tab</div>
              <p className="text-neutral-400">Configure display modes, presentation styles, arrow visibility, and toggle Launch at Login.</p>
            </div>
            <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
              <div className="font-semibold text-white">Documentation Tab</div>
              <p className="text-neutral-400">Browse offline user guides, installation guides, terms, and privacy policy directly in-app.</p>
            </div>
            <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
              <div className="font-semibold text-white">About Tab</div>
              <p className="text-neutral-400">View build metadata, copyright disclosures, license terms, and platform compatibility.</p>
            </div>
          </div>
        </div>

        {/* Section 4: Privacy Guarantees */}
        <div className="p-8 rounded-3xl bg-[#0F0F14] border border-white/[0.08] space-y-4">
          <h2 className="text-xl font-bold text-white flex items-center gap-2.5">
            <Shield className="w-5 h-5 text-emerald-400" />
            4. Privacy & Offline Architecture
          </h2>
          <p className="text-xs sm:text-sm text-neutral-300 leading-relaxed">
            ANC operates entirely locally on your Mac. It never makes outbound network connections, bundles zero telemetry or tracking SDKs, and stores only your chosen display settings on your device.
          </p>
          <div className="space-y-2 pt-2 text-xs text-neutral-400">
            <div className="flex items-start gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
              <span><strong>Zero Telemetry:</strong> No usage metrics, error logs, or personal information are ever recorded or transmitted.</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 mt-1.5 shrink-0" />
              <span><strong>Local Storage Only:</strong> Only your selected display preferences are saved locally on your Mac.</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
