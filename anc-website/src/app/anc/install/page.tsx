import React from "react";
import type { Metadata } from "next";
import Link from "next/link";
import {
  Download,
  FolderArchive,
  FolderInput,
  PlaySquare,
  ShieldAlert,
  PanelTop,
  Power,
  HelpCircle,
  AlertTriangle,
  CheckCircle2,
  ExternalLink,
  ChevronRight
} from "lucide-react";
import { latestRelease } from "@/data/releases";

export const metadata: Metadata = {
  title: "Installation & Setup Guide",
  description:
    "Step-by-step installation instructions for ARRY Network Counter on macOS. Complete Gatekeeper approval guide, menu-bar setup, and troubleshooting.",
};

export default function InstallPage() {
  const steps = [
    {
      step: "01",
      title: "Download the Official DMG",
      icon: Download,
      content:
        "Download the latest release package (ARRY-Network-Counter.dmg) directly from the official ARRRY download center. Do not download ANC from third-party sites.",
      actionText: "Go to Download Center",
      actionHref: "/anc/download",
    },
    {
      step: "02",
      title: "Mount the Disk Image",
      icon: FolderArchive,
      content:
        "Locate ARRY-Network-Counter.dmg in your Downloads folder and double-click it. macOS will mount the volume and present a Finder window with the application and a shortcut to your Applications folder.",
    },
    {
      step: "03",
      title: "Drag to Applications",
      icon: FolderInput,
      content:
        "Drag the ARRY Network Counter application icon into the Applications folder shortcut. This copies the self-contained universal application bundle to /Applications.",
    },
    {
      step: "04",
      title: "Launch the Application",
      icon: PlaySquare,
      content:
        "Open your Applications folder in Finder or press Command + Space to open Spotlight, type 'ARRY Network Counter', and press Return.",
    },
    {
      step: "05",
      title: "First-Launch Gatekeeper Verification",
      icon: ShieldAlert,
      isGatekeeper: true,
      content:
        "Because this initial v1.0.0 release is ad-hoc signed for personal/developer testing without an Apple Developer ID notarization ticket, macOS Gatekeeper may display a security prompt on initial launch.",
    },
    {
      step: "06",
      title: "Locate in Your Menu Bar",
      icon: PanelTop,
      content:
        "ARRY Network Counter is architected strictly as a menu-bar accessory (LSUIElement). It does NOT appear in your Dock or Command-Tab switcher. Look for the throughput monitor (e.g. ↓ 0 B/s  ↑ 0 B/s) on the trailing side of your top menu bar.",
    },
    {
      step: "07",
      title: "Optional Launch at Login",
      icon: Power,
      content:
        "Click the ANC status item in your menu bar, choose Settings, and check 'Launch at Login' in the General section. ANC registers natively with macOS Login Items using Apple's SMAppService API.",
    },
  ];

  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-16">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>OFFICIAL SETUP INSTRUCTIONS</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Installation Guide
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Follow this visual guide to install and configure ARRY Network Counter on macOS 13.0 or later.
          </p>
        </div>

        {/* System Requirements Callout */}
        <div className="p-6 rounded-2xl bg-[#0E0E14] border border-white/[0.08] flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="space-y-1">
            <h3 className="text-sm font-semibold text-white">System Requirements</h3>
            <p className="text-xs text-neutral-400">
              macOS 13.0 (Ventura), 14.0 (Sonoma), or 15.0+ (Sequoia) · Universal Binary (arm64 Apple Silicon + x86_64 Intel)
            </p>
          </div>
          <span className="px-3 py-1 rounded-full text-xs font-mono bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 shrink-0">
            Self-Contained · No Dependencies
          </span>
        </div>

        {/* Steps List */}
        <div className="space-y-8">
          {steps.map((item) => (
            <div
              key={item.step}
              className={`p-6 sm:p-8 rounded-3xl bg-[#111116]/80 backdrop-blur-xl border ${
                item.isGatekeeper ? "border-amber-500/30 bg-[#161410]/70" : "border-white/[0.08]"
              } shadow-lg space-y-4`}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <span className="font-mono text-xs font-bold text-neutral-500 px-2.5 py-1 rounded-lg bg-white/5 border border-white/10">
                    STEP {item.step}
                  </span>
                  <h3 className="text-lg font-bold text-white tracking-tight flex items-center gap-2">
                    <item.icon className={`w-5 h-5 ${item.isGatekeeper ? "text-amber-400" : "text-emerald-400"}`} />
                    {item.title}
                  </h3>
                </div>
              </div>

              <p className="text-sm text-neutral-300 leading-relaxed">
                {item.content}
              </p>

              {item.isGatekeeper && (
                <div className="pt-2 space-y-4">
                  <div className="p-4 rounded-xl bg-amber-500/10 border border-amber-500/20 text-xs text-amber-200/90 space-y-2">
                    <div className="font-semibold flex items-center gap-1.5 text-amber-300">
                      <AlertTriangle className="w-4 h-4" />
                      Two Verified Methods to Open Ad-Hoc Signed Builds:
                    </div>
                    <div className="space-y-2 pt-1 text-xs">
                      <div>
                        <strong className="text-white">Method A (Recommended):</strong> In Finder, navigate to <code className="text-amber-300 font-mono">/Applications</code>, right-click (or Control-click) <strong className="text-white">ARRY Network Counter.app</strong>, and choose <strong className="text-white">Open</strong>. In the dialog, click <strong className="text-white">Open</strong>. macOS records your approval and will not prompt again.
                      </div>
                      <div>
                        <strong className="text-white">Method B:</strong> If blocked upon opening, open <strong className="text-white">macOS System Settings → Privacy & Security</strong>, scroll down to <strong className="text-white">Security</strong>, and click <strong className="text-white">Open Anyway</strong> next to ARRY Network Counter.
                      </div>
                    </div>
                  </div>
                  <div className="text-[11px] text-neutral-400">
                    <strong>Important Security Note:</strong> Never disable Gatekeeper globally via Terminal commands. Future production updates will be signed with Apple Developer ID certificates and notarized by Apple.
                  </div>
                </div>
              )}

              {item.actionText && item.actionHref && (
                <div className="pt-2">
                  <Link
                    href={item.actionHref}
                    className="inline-flex items-center gap-2 text-xs font-semibold text-emerald-400 hover:text-emerald-300 transition-colors"
                  >
                    <span>{item.actionText}</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Troubleshooting Section */}
        <div id="troubleshooting" className="pt-12 border-t border-white/[0.08] space-y-6">
          <div className="flex items-center gap-2 text-sm font-semibold text-neutral-300 uppercase tracking-wider">
            <HelpCircle className="w-4 h-4 text-emerald-400" />
            Troubleshooting Common Questions
          </div>

          <div className="space-y-4">
            {[
              {
                q: "Why is ARRY Network Counter not visible in my Dock?",
                a: "ANC is deliberately built as a menu-bar-only accessory (LSUIElement = true). It does not have a Dock icon or an entry in the Command-Tab switcher. Look for the throughput monitor in the top right menu bar.",
              },
              {
                q: "What if the application is missing from the menu bar?",
                a: "If your Mac has a notch or a crowded menu bar, macOS may temporarily hide menu extras. Try closing unused menu-bar items or check System Settings > Control Center to ensure menu extras are allowed.",
              },
              {
                q: "How do I replace an older version of ANC?",
                a: "Download the updated DMG, open it, and drag ARRY Network Counter to Applications. Click 'Replace' when macOS asks. Your saved display preferences in UserDefaults will be preserved.",
              },
              {
                q: "How do I completely remove the application and preferences?",
                a: "Quit ANC, delete 'ARRY Network Counter.app' from /Applications, and run 'defaults delete in.arrry.networkcounter' in Terminal to wipe saved settings.",
              },
            ].map((faq, i) => (
              <div key={i} className="p-5 rounded-2xl bg-[#0E0E14] border border-white/[0.06] space-y-1.5">
                <h4 className="text-xs font-semibold text-white">{faq.q}</h4>
                <p className="text-xs text-neutral-400 leading-relaxed">{faq.a}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
