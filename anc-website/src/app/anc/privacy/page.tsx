import React from "react";
import type { Metadata } from "next";
import { Shield, Lock, EyeOff, HardDrive, Server, FileText } from "lucide-react";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "Official privacy policy for ARRY Network Counter (ANC) macOS application and the official anc.arrry.in product website.",
};

export default function PrivacyPage() {
  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-12">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-xs font-mono text-emerald-400">
            <Shield className="w-3.5 h-3.5" />
            <span>LOCAL-FIRST PRIVACY POLICY</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Privacy Policy
          </h1>
          <p className="text-xs sm:text-sm text-neutral-400">
            Effective Date: January 1, 2026 · Product: ARRY Network Counter (ANC) · Brand: ARRRY
          </p>
        </div>

        {/* Intro */}
        <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] text-xs sm:text-sm text-neutral-300 leading-relaxed space-y-3">
          <p>
            ARRRY (&quot;we&quot;, &quot;us&quot;, or &quot;our&quot;) has developed <strong>ARRY Network Counter (ANC)</strong> with an architecture centered on privacy, local device processing, and operational transparency.
          </p>
          <p>
            This Privacy Policy describes how data is handled across both the <strong>native macOS application</strong> and this <strong>official product website</strong> (<code className="text-emerald-400 font-mono">anc.arrry.in</code>). Every statement in this policy is directly backed by source-code verification.
          </p>
        </div>

        {/* Summary Table */}
        <div className="rounded-2xl bg-[#0F0F14] border border-white/[0.08] overflow-hidden">
          <div className="p-4 bg-white/[0.02] border-b border-white/[0.06] text-xs font-semibold text-white">
            Summary of Application Data Practices
          </div>
          <div className="divide-y divide-white/[0.06] text-xs">
            {[
              { cat: "Remote Network Transmission", val: "None. The application makes zero outbound or inbound network connections." },
              { cat: "Telemetry & Analytics", val: "None. No analytics SDKs, trackers, or telemetry reporting tools are bundled." },
              { cat: "Crash Reporting", val: "None. No crash-reporting frameworks or remote diagnostic loggers are used." },
              { cat: "Personal Information (PII)", val: "None. No names, email addresses, IP addresses, or device identifiers are collected." },
              { cat: "Network Traffic Inspection", val: "None. Packet payloads, visited URLs, DNS requests, and content are never accessed." },
              { cat: "Throughput Processing", val: "In-Memory Only. Kernel byte counters are evaluated in volatile RAM and discarded." },
              { cat: "Persistent Storage", val: "Local Preferences Only. 4 user configuration settings saved in UserDefaults." },
            ].map((row, i) => (
              <div key={i} className="grid grid-cols-1 sm:grid-cols-3 p-4 hover:bg-white/[0.01]">
                <div className="font-medium text-neutral-400">{row.cat}</div>
                <div className="sm:col-span-2 font-mono text-neutral-200 mt-1 sm:mt-0 font-medium">{row.val}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Section 2: In-Memory Throughput Processing */}
        <div className="space-y-4">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Lock className="w-4 h-4 text-emerald-400" />
            2. In-Memory Throughput Processing
          </h2>
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] text-xs sm:text-sm text-neutral-300 leading-relaxed space-y-3">
            <p>
              To calculate and display your network speeds, ARRY Network Counter queries standard macOS kernel network statistics via the operating system&apos;s BSD <code className="text-emerald-400 font-mono">getifaddrs</code> interface.
            </p>
            <div className="space-y-1.5 pl-2 text-xs text-neutral-400">
              <div>• <strong>Cumulative Byte Counters:</strong> Evaluates total received (<code className="text-neutral-300 font-mono">ifi_ibytes</code>) and transmitted (<code className="text-neutral-300 font-mono">ifi_obytes</code>) bytes reported by the OS for network interfaces (e.g. <code className="text-neutral-300 font-mono">en0</code>).</div>
              <div>• <strong>Path State:</strong> Monitors interface connectivity (Wi-Fi, Ethernet, Loopback) using Apple&apos;s <code className="text-neutral-300 font-mono">NWPathMonitor</code>.</div>
              <div>• <strong>Elapsed Time:</strong> High-resolution monotonic system time (<code className="text-neutral-300 font-mono">clock_gettime_nsec_np</code>) calculates speed as difference in bytes divided by elapsed seconds (Δbytes / Δt).</div>
            </div>
            <p className="pt-2 font-semibold text-white">What is NOT evaluated or accessed:</p>
            <div className="space-y-1 pl-2 text-xs text-neutral-400">
              <div>• Does NOT perform packet inspection or packet sniffing.</div>
              <div>• Does NOT read packet headers or payloads.</div>
              <div>• Does NOT record visited websites, URLs, domains, or web traffic.</div>
              <div>• Does NOT monitor DNS lookups, ports, or protocols.</div>
              <div>• Does NOT log IP addresses of servers or computers with which you communicate.</div>
            </div>
            <p className="pt-2 text-xs text-neutral-400">
              <strong>Volatile Retention:</strong> All speed measurements exist strictly in volatile RAM. They are continuously overwritten as new 1-second samples arrive and are completely purged from memory when the app is quit.
            </p>
          </div>
        </div>

        {/* Section 3: Local Storage */}
        <div className="space-y-4">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <HardDrive className="w-4 h-4 text-emerald-400" />
            3. Local Storage (UserDefaults)
          </h2>
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] text-xs sm:text-sm text-neutral-300 leading-relaxed space-y-3">
            <p>
              ARRY Network Counter persists only application configuration settings locally on your Mac using standard macOS <code className="text-emerald-400 font-mono">UserDefaults</code> in the domain <code className="text-emerald-400 font-mono">in.arrry.networkcounter</code>:
            </p>
            <div className="p-3 bg-black/40 rounded-xl border border-white/5 font-mono text-xs text-neutral-300 space-y-1">
              <div>1. displayMode: Presentation mode (bothDirections, singleDirectionManual, singleDirectionAutomatic)</div>
              <div>2. bothDirectionsStyle: Presentation style (separateSpeeds, combinedArrows, withoutArrows)</div>
              <div>3. manualDirection: Selected direction for manual mode (download, upload)</div>
              <div>4. launchAtLogin: Boolean flag reflecting login item registration</div>
            </div>
            <p className="text-xs text-neutral-400">
              No personal data, device identifiers, or usage logs are ever stored in UserDefaults or on your filesystem.
            </p>
          </div>
        </div>

        {/* Section 4: Website and Infrastructure Disclosures */}
        <div className="space-y-4">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Server className="w-4 h-4 text-sky-400" />
            4. Official Website & Infrastructure Disclosures
          </h2>
          <div className="p-6 rounded-2xl bg-[#0F0F14] border border-white/[0.08] text-xs sm:text-sm text-neutral-300 leading-relaxed space-y-3">
            <p>
              The official product website (<code className="text-sky-300 font-mono">anc.arrry.in</code>) is engineered with the same privacy principles:
            </p>
            <div className="space-y-1.5 pl-2 text-xs text-neutral-400">
              <div>• <strong>No Tracking Cookies:</strong> This website does not use tracking cookies, advertising identifiers, or marketing analytics SDKs.</div>
              <div>• <strong>Cloudflare R2 Object Storage:</strong> Application DMG downloads are hosted on Cloudflare R2 (<code className="text-sky-300 font-mono">downloads.arrry.in</code>). Cloudflare operates edge servers that may log standard technical HTTP request headers (IP address, user agent) as necessary to deliver files and protect against denial-of-service attacks.</div>
              <div>• <strong>Static Delivery:</strong> Web pages are statically pre-rendered with zero user data harvesting.</div>
            </div>
          </div>
        </div>

        {/* Section 5: Notice on Legal Entity & Contact */}
        <div className="p-6 rounded-2xl bg-amber-500/10 border border-amber-500/20 text-xs sm:text-sm text-amber-200/90 space-y-2">
          <div className="font-semibold text-amber-300 flex items-center gap-1.5">
            <FileText className="w-4 h-4" />
            Notice on Verification & Legal Contact Channels:
          </div>
          <p className="text-xs text-neutral-300 leading-relaxed">
            Specific corporate entity registration details, physical business addresses, and commercial support channels require project owner confirmation and are intentionally omitted from this initial product release. For security disclosures or technical privacy inquiries related to this codebase, please submit an issue through the official ARRRY project repository.
          </p>
        </div>
      </div>
    </div>
  );
}
