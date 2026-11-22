import React from "react";
import Link from "next/link";
import Image from "next/image";
import { Shield, Cpu, Activity, Download, ArrowUpRight } from "lucide-react";

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="relative bg-[#050508] border-t border-white/[0.08] text-neutral-400 text-xs overflow-hidden">
      {/* Subtle background glow */}
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-emerald-500/30 to-transparent" />
      <div className="absolute left-1/2 -top-24 -translate-x-1/2 w-96 h-48 bg-emerald-500/5 blur-3xl pointer-events-none rounded-full" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-10 lg:gap-12">
          {/* Brand info */}
          <div className="md:col-span-2 space-y-4">
            <Link href="/anc" className="flex items-center gap-3 group inline-flex">
              <div className="relative w-8 h-8 rounded-lg overflow-hidden border border-white/10 shadow-sm">
                <Image
                  src="/images/app-icon.png"
                  alt="ANC App Icon"
                  fill
                  sizes="32px"
                  className="object-cover"
                />
              </div>
              <div className="flex flex-col">
                <span className="text-white font-semibold text-sm tracking-tight group-hover:text-emerald-400 transition-colors">
                  ARRY Network Counter
                </span>
                <span className="text-[10px] text-neutral-500 font-mono">
                  by ARRRY
                </span>
              </div>
            </Link>

            <p className="text-neutral-400 leading-relaxed text-xs max-w-sm">
              A lightweight, privacy-focused native macOS menu-bar utility designed for real-time download and upload throughput monitoring. Built in Swift 6 for minimal memory and CPU usage.
            </p>

            <div className="flex flex-wrap items-center gap-2 pt-2">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-[11px] text-neutral-300">
                <Shield className="w-3 h-3 text-emerald-400" />
                macOS Ventura or later
              </span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-[11px] text-neutral-300">
                <Cpu className="w-3 h-3 text-sky-400" />
                Apple Silicon & Intel
              </span>
            </div>
          </div>

          {/* Navigation Links */}
          <div className="space-y-3">
            <h4 className="text-xs font-semibold text-neutral-200 tracking-wider uppercase">
              Product
            </h4>
            <ul className="space-y-2">
              <li>
                <Link href="/anc/features" className="hover:text-white transition-colors">
                  Features
                </Link>
              </li>
              <li>
                <Link href="/anc/download" className="hover:text-white transition-colors flex items-center gap-1">
                  Download Center
                </Link>
              </li>
              <li>
                <Link href="/anc/install" className="hover:text-white transition-colors">
                  Installation Guide
                </Link>
              </li>
              <li>
                <Link href="/anc/changelog" className="hover:text-white transition-colors">
                  Release History
                </Link>
              </li>
            </ul>
          </div>

          {/* Documentation Links */}
          <div className="space-y-3">
            <h4 className="text-xs font-semibold text-neutral-200 tracking-wider uppercase">
              Documentation
            </h4>
            <ul className="space-y-2">
              <li>
                <Link href="/anc/guide" className="hover:text-white transition-colors">
                  User & Operations Guide
                </Link>
              </li>
              <li>
                <Link href="/anc/faq" className="hover:text-white transition-colors">
                  Frequently Asked Questions
                </Link>
              </li>
              <li>
                <Link href="/anc/install#troubleshooting" className="hover:text-white transition-colors">
                  Gatekeeper & Setup Help
                </Link>
              </li>
              <li>
                <Link href="/anc/download/latest" className="hover:text-white transition-colors flex items-center gap-1">
                  Direct Latest DMG <ArrowUpRight className="w-3 h-3" />
                </Link>
              </li>
            </ul>
          </div>

          {/* Legal & Governance */}
          <div className="space-y-3">
            <h4 className="text-xs font-semibold text-neutral-200 tracking-wider uppercase">
              Legal
            </h4>
            <ul className="space-y-2">
              <li>
                <Link href="/anc/privacy" className="hover:text-white transition-colors">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link href="/anc/terms" className="hover:text-white transition-colors">
                  Terms and Conditions
                </Link>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom copyright and legal disclaimer */}
        <div className="mt-12 pt-8 border-t border-white/[0.06] flex flex-col sm:flex-row items-center justify-between gap-4 text-[11px] text-neutral-500">
          <div>
            © {currentYear} ARRRY. All rights reserved. ARRY Network Counter is an independent software utility.
          </div>
          <div className="flex items-center gap-4">
            <span>Apple, macOS, and Finder are trademarks of Apple Inc.</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
