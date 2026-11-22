"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { Menu, X, Download, ShieldCheck, Cpu } from "lucide-react";

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navLinks = [
    { href: "/anc/features", label: "Features" },
    { href: "/anc/install", label: "Installation" },
    { href: "/anc/guide", label: "Documentation" },
    { href: "/anc/changelog", label: "Changelog" },
    { href: "/anc/faq", label: "FAQ" },
  ];

  const isActive = (href: string) => {
    return pathname === href || pathname === href.replace(/^\/anc/, "");
  };

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-[#09090D]/80 backdrop-blur-xl border-b border-white/[0.08] shadow-[0_4px_30px_rgba(0,0,0,0.5)]"
          : "bg-transparent border-b border-transparent"
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 md:h-20">
          {/* Brand Identity */}
          <Link
            href="/anc"
            className="flex items-center gap-3 group focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 rounded-xl p-1"
          >
            <div className="relative w-9 h-9 md:w-10 md:h-10 rounded-xl overflow-hidden shadow-[0_2px_12px_rgba(48,184,107,0.25)] border border-white/10 group-hover:scale-105 transition-transform duration-300">
              <Image
                src="/images/app-icon.png"
                alt="ARRY Network Counter App Icon"
                fill
                sizes="40px"
                className="object-cover"
                priority
              />
            </div>
            <div className="flex flex-col">
              <span className="font-semibold text-sm md:text-base tracking-tight text-white group-hover:text-emerald-400 transition-colors">
                ARRY Network Counter
              </span>
              <span className="text-[10px] md:text-xs text-neutral-400 font-mono tracking-wider uppercase">
                ANC · v1.0.0
              </span>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-1 bg-white/[0.03] border border-white/[0.06] rounded-full px-4 py-1.5 backdrop-blur-md">
            {navLinks.map((link) => {
              const active = isActive(link.href);
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200 ${
                    active
                      ? "text-white bg-white/10 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.15)]"
                      : "text-neutral-400 hover:text-white hover:bg-white/[0.04]"
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
          </nav>

          {/* Download CTA Action */}
          <div className="hidden md:flex items-center gap-3">
            <Link
              href="/anc/download"
              className="group relative inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-gradient-to-b from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 shadow-[0_2px_12px_rgba(48,184,107,0.35),inset_0_1px_0_0_rgba(255,255,255,0.25)] active:scale-95 transition-all duration-200"
            >
              <Download className="w-3.5 h-3.5 group-hover:translate-y-0.5 transition-transform" />
              <span>Download for macOS</span>
            </Link>
          </div>

          {/* Mobile Menu Toggle */}
          <div className="flex md:hidden">
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-xl text-neutral-400 hover:text-white hover:bg-white/10 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500"
              aria-label="Toggle navigation menu"
              aria-expanded={mobileMenuOpen}
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-[#0A0A0F]/95 backdrop-blur-2xl border-b border-white/10 px-4 pt-3 pb-6 space-y-2 animate-in slide-in-from-top duration-200">
          <nav className="flex flex-col gap-1">
            {navLinks.map((link) => {
              const active = isActive(link.href);
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`px-4 py-2.5 rounded-xl text-sm font-medium transition-colors ${
                    active
                      ? "text-emerald-400 bg-emerald-500/10 border border-emerald-500/20"
                      : "text-neutral-300 hover:text-white hover:bg-white/5"
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
          </nav>
          <div className="pt-3 border-t border-white/10">
            <Link
              href="/anc/download"
              onClick={() => setMobileMenuOpen(false)}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-500 shadow-[0_2px_12px_rgba(48,184,107,0.35)] transition-all"
            >
              <Download className="w-4 h-4" />
              <span>Download ARRY Network Counter</span>
            </Link>
          </div>
        </div>
      )}
    </header>
  );
}
