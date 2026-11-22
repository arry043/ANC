"use client";

import React, { useState, useEffect, useMemo } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  SlidersHorizontal,
  BookOpen,
  Info,
  CheckCircle2,
  Wifi,
  Battery,
  Sliders,
  Search,
  ExternalLink,
  ChevronRight,
  ArrowDown,
  ArrowUp,
  Activity,
  Sparkles,
  RefreshCw,
  FileText,
  Eye,
  EyeOff,
  ChevronDown
} from "lucide-react";
import { formatSpeed } from "@/lib/utils";
import {
  DisplayMode,
  BothDirectionsStyle,
  SingleDirectionArrowStyle,
  NetworkDirection,
} from "@/types/release";

// Exact colors from MenuBarAppearance.swift
const DOWNLOAD_COLOR = "#30B86B"; // Emerald green
const UPLOAD_COLOR = "#3988E8";   // Electric blue

type TabType = "preferences" | "documentation" | "about";

interface SpeedPreset {
  name: string;
  label: string;
  downloadBps: number;
  uploadBps: number;
  description: string;
}

const PRESETS: SpeedPreset[] = [
  {
    name: "browsing",
    label: "Active Web Browsing",
    downloadBps: 2_450_000, // 2.45 MB/s
    uploadBps: 120_000,     // 120 KB/s
    description: "Standard active download dominance with occasional uplink acknowledgements.",
  },
  {
    name: "streaming",
    label: "4K Video Stream",
    downloadBps: 18_500_000, // 18.5 MB/s
    uploadBps: 45_000,       // 45 KB/s
    description: "High continuous downlink throughput.",
  },
  {
    name: "uploading",
    label: "Cloud Video Backup",
    downloadBps: 320_000,    // 320 KB/s
    uploadBps: 12_400_000,   // 12.4 MB/s
    description: "Heavy uplink dominance triggering automatic direction switching.",
  },
  {
    name: "balanced",
    label: "Balanced Traffic",
    downloadBps: 1_450_000,  // 1.45 MB/s
    uploadBps: 1_400_000,    // 1.40 MB/s
    description: "Nearly equal rates demonstrating 3-factor hysteresis flapping protection.",
  },
  {
    name: "idle",
    label: "Idle Connection",
    downloadBps: 0,
    uploadBps: 0,
    description: "Zero network activity, rendering standard macOS '0 KB/s' baseline.",
  },
];

export function ANCPlayground() {
  // Navigation & Settings state
  const [activeTab, setActiveTab] = useState<TabType>("preferences");
  const [displayMode, setDisplayMode] = useState<DisplayMode>("bothDirections");
  const [bothDirectionsStyle, setBothDirectionsStyle] = useState<BothDirectionsStyle>("separateSpeeds");
  const [manualDirection, setManualDirection] = useState<NetworkDirection>("download");
  const [singleDirectionArrowStyle, setSingleDirectionArrowStyle] = useState<SingleDirectionArrowStyle>("withArrow");
  const [launchAtLogin, setLaunchAtLogin] = useState<boolean>(true);

  // Simulation engine state
  const [downloadBps, setDownloadBps] = useState<number>(2_450_000);
  const [uploadBps, setUploadBps] = useState<number>(120_000);
  const [activePreset, setActivePreset] = useState<string>("browsing");

  // Hysteresis calculation state
  const [dominantDirection, setDominantDirection] = useState<NetworkDirection>("download");
  const [candidateDirection, setCandidateDirection] = useState<NetworkDirection | null>(null);
  const [consecutiveCount, setConsecutiveCount] = useState<number>(0);
  const [didSwitch, setDidSwitch] = useState<boolean>(false);

  // Menu bar simulated dropdown
  const [menuBarDropdownOpen, setMenuBarDropdownOpen] = useState<boolean>(false);
  const [selectedDocModal, setSelectedDocModal] = useState<string | null>(null);

  // Simulate DominantDirectionEngine hysteresis logic
  useEffect(() => {
    // 3-factor hysteresis rules:
    // 1. Relative Margin: Opposite rate must exceed active rate by >= 10%
    // 2. Absolute Noise Floor: Absolute rate difference must exceed 10,000 B/s (10 KB/s)
    // 3. 2 Consecutive Samples
    const currentRate = dominantDirection === "download" ? downloadBps : uploadBps;
    const opposingRate = dominantDirection === "download" ? uploadBps : downloadBps;
    const opposingDir: NetworkDirection = dominantDirection === "download" ? "upload" : "download";

    const relativeQualifies = opposingRate >= currentRate * 1.10;
    const absoluteQualifies = (opposingRate - currentRate) >= 10_000;

    if (downloadBps === 0 && uploadBps === 0) {
      setDominantDirection("download");
      setCandidateDirection(null);
      setConsecutiveCount(0);
      setDidSwitch(false);
      return;
    }

    if (relativeQualifies && absoluteQualifies) {
      if (candidateDirection === opposingDir) {
        // Second qualifying sample -> switch!
        setDominantDirection(opposingDir);
        setCandidateDirection(null);
        setConsecutiveCount(2);
        setDidSwitch(true);
      } else {
        // First qualifying sample
        setCandidateDirection(opposingDir);
        setConsecutiveCount(1);
        setDidSwitch(false);
      }
    } else {
      // Recovery or invalid spike -> discard pending candidate
      setCandidateDirection(null);
      setConsecutiveCount(0);
      setDidSwitch(false);
    }
  }, [downloadBps, uploadBps, dominantDirection, candidateDirection]);

  const dlFormatted = useMemo(() => formatSpeed(downloadBps), [downloadBps]);
  const ulFormatted = useMemo(() => formatSpeed(uploadBps), [uploadBps]);

  // Determine dominant speed formatted
  const dominantSpeedFormatted = dominantDirection === "download" ? dlFormatted : ulFormatted;

  // Apply a speed preset
  const applyPreset = (preset: SpeedPreset) => {
    setActivePreset(preset.name);
    setDownloadBps(preset.downloadBps);
    setUploadBps(preset.uploadBps);
  };

  // Render the menu bar text output matching ANC exactly
  const renderMenuBarOutput = () => {
    if (displayMode === "bothDirections") {
      switch (bothDirectionsStyle) {
        case "separateSpeeds":
          return (
            <div className="flex items-center space-x-1.5 font-medium tracking-tight text-[11.5px]">
              <span style={{ color: DOWNLOAD_COLOR }} className="font-semibold text-xs leading-none">↓</span>
              <span className="font-mono text-neutral-100">{dlFormatted.displayString}</span>
              <span className="w-2.5" />
              <span style={{ color: UPLOAD_COLOR }} className="font-semibold text-xs leading-none">↑</span>
              <span className="font-mono text-neutral-100">{ulFormatted.displayString}</span>
            </div>
          );
        case "combinedArrows":
          return (
            <div className="flex items-center space-x-1.5 font-medium tracking-tight text-[11.5px]">
              <span style={{ color: DOWNLOAD_COLOR }} className="font-semibold text-xs leading-none">↓</span>
              <span style={{ color: UPLOAD_COLOR }} className="font-semibold text-xs leading-none">↑</span>
              <span className="font-mono text-neutral-100">{dominantSpeedFormatted.displayString}</span>
            </div>
          );
        case "withoutArrows":
          return (
            <div className="flex items-center space-x-1.5 font-medium tracking-tight text-[11.5px]">
              <span style={{ color: DOWNLOAD_COLOR }} className="font-bold text-[10.5px] leading-none">DL</span>
              <span className="font-mono text-neutral-100">{dlFormatted.displayString}</span>
              <span className="w-2.5" />
              <span style={{ color: UPLOAD_COLOR }} className="font-bold text-[10.5px] leading-none">UL</span>
              <span className="font-mono text-neutral-100">{ulFormatted.displayString}</span>
            </div>
          );
      }
    } else if (displayMode === "singleDirectionManual") {
      const isDl = manualDirection === "download";
      const speed = isDl ? dlFormatted : ulFormatted;
      const arrow = isDl ? "↓" : "↑";
      const color = isDl ? DOWNLOAD_COLOR : UPLOAD_COLOR;

      return (
        <div className="flex items-center space-x-1.5 font-medium tracking-tight text-[11.5px]">
          {singleDirectionArrowStyle === "withArrow" && (
            <span style={{ color }} className="font-semibold text-xs leading-none">{arrow}</span>
          )}
          <span className="font-mono text-neutral-100">{speed.displayString}</span>
        </div>
      );
    } else {
      // singleDirectionAutomatic
      const isDl = dominantDirection === "download";
      const arrow = isDl ? "↓" : "↑";
      const color = isDl ? DOWNLOAD_COLOR : UPLOAD_COLOR;

      return (
        <div className="flex items-center space-x-1.5 font-medium tracking-tight text-[11.5px]">
          {singleDirectionArrowStyle === "withArrow" && (
            <span style={{ color }} className="font-semibold text-xs leading-none">{arrow}</span>
          )}
          <span className="font-mono text-neutral-100">{dominantSpeedFormatted.displayString}</span>
        </div>
      );
    }
  };

  return (
    <div className="w-full relative">
      {/* Simulation Header Badge */}
      <div className="flex flex-wrap items-center justify-between gap-3 mb-6 px-1">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-mono tracking-wide">
          <Activity className="w-3.5 h-3.5 animate-pulse" />
          <span>INTERACTIVE PRODUCT PLAYGROUND · FULL SIMULATION</span>
        </div>
        <div className="text-xs text-neutral-400">
          Try changing settings below to preview the menu bar live
        </div>
      </div>

      {/* Connected Two-Panel Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* LEFT PANEL: Interactive Settings Window (col-span-7) */}
        <div className="lg:col-span-7 w-full bg-[#18181C]/90 backdrop-blur-2xl rounded-2xl border border-white/[0.12] shadow-[0_20px_50px_rgba(0,0,0,0.6),inset_0_1px_0_0_rgba(255,255,255,0.15)] overflow-hidden transition-all duration-300">
          {/* macOS Window Chrome Header */}
          <div className="px-4 py-3 bg-[#1C1C22]/80 border-b border-white/[0.08] flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <span className="w-3 h-3 rounded-full bg-[#FF5F56] border border-[#E0443E]/50 shadow-sm" />
              <span className="w-3 h-3 rounded-full bg-[#FFBD2E] border border-[#DEA123]/50 shadow-sm" />
              <span className="w-3 h-3 rounded-full bg-[#27C93F] border border-[#1AAB29]/50 shadow-sm" />
            </div>
            <div className="text-xs font-medium text-neutral-300 tracking-tight">
              ARRY Network Counter Settings
            </div>
            <div className="w-12" /> {/* balance spacing */}
          </div>

          {/* Segmented Tab Bar - Centered (Exact macOS segmented control) */}
          <div className="px-6 pt-3 pb-3 flex justify-center border-b border-white/[0.06]">
            <div className="inline-flex items-center p-0.5 bg-[#25252A] rounded-lg border border-white/[0.08] text-xs">
              <button
                onClick={() => setActiveTab("preferences")}
                className={`px-4 py-1.5 rounded-md transition-all duration-150 text-xs ${
                  activeTab === "preferences"
                    ? "bg-[#007AFF] text-white font-medium shadow-sm"
                    : "text-neutral-300 hover:text-white"
                }`}
              >
                Preferences
              </button>

              <button
                onClick={() => setActiveTab("documentation")}
                className={`px-4 py-1.5 rounded-md transition-all duration-150 text-xs ${
                  activeTab === "documentation"
                    ? "bg-[#007AFF] text-white font-medium shadow-sm"
                    : "text-neutral-300 hover:text-white"
                }`}
              >
                Documentation
              </button>

              <button
                onClick={() => setActiveTab("about")}
                className={`px-4 py-1.5 rounded-md transition-all duration-150 text-xs ${
                  activeTab === "about"
                    ? "bg-[#007AFF] text-white font-medium shadow-sm"
                    : "text-neutral-300 hover:text-white"
                }`}
              >
                About
              </button>
            </div>
          </div>

          {/* Tab Content Area */}
          <div className="p-6 min-h-[460px]">
            {activeTab === "preferences" && (
              <div className="space-y-6 animate-in fade-in duration-200">
                {/* Header Section */}
                <div className="flex items-center gap-3.5 pb-4 border-b border-white/[0.08]">
                  <div className="relative w-10 h-10 rounded-xl overflow-hidden border border-white/10 shadow-sm shrink-0">
                    <Image
                      src="/images/app-logo.png"
                      alt="ANC Logo"
                      fill
                      sizes="40px"
                      className="object-cover"
                    />
                  </div>
                  <div>
                    <h3 className="text-sm font-semibold text-white tracking-tight">
                      ARRY Network Counter
                    </h3>
                    <p className="text-xs text-neutral-400">
                      Version 1.0.0 • Native macOS Network Monitor
                    </p>
                  </div>
                </div>

                {/* Display Mode Section */}
                <div className="space-y-3">
                  <label className="text-xs font-semibold text-neutral-200 uppercase tracking-wider">
                    Display Mode
                  </label>
                  <div className="space-y-2">
                    {[
                      { id: "bothDirections", label: "Both Directions" },
                      { id: "singleDirectionManual", label: "Single Direction — Manual" },
                      { id: "singleDirectionAutomatic", label: "Single Direction — Automatic" },
                    ].map((mode) => (
                      <label
                        key={mode.id}
                        className="flex items-center gap-3 cursor-pointer group select-none text-xs text-neutral-300 hover:text-white"
                      >
                        <input
                          type="radio"
                          name="displayMode"
                          checked={displayMode === mode.id}
                          onChange={() => setDisplayMode(mode.id as DisplayMode)}
                          className="w-4 h-4 text-blue-500 bg-[#282830] border-neutral-600 focus:ring-0 focus:ring-offset-0 cursor-pointer accent-blue-500"
                        />
                        <span className="font-medium">{mode.label}</span>
                      </label>
                    ))}
                  </div>
                </div>

                {/* Conditional Sub-controls */}
                <div className="pl-4 border-l border-white/10 space-y-4">
                  {displayMode === "bothDirections" && (
                    <div className="space-y-3">
                      <label className="text-xs font-medium text-neutral-300">
                        Presentation Style
                      </label>
                      <div className="space-y-2">
                        {[
                          { id: "separateSpeeds", label: "Separate Speeds" },
                          { id: "combinedArrows", label: "Combined Arrows" },
                          { id: "withoutArrows", label: "Without Arrows" },
                        ].map((style) => (
                          <label
                            key={style.id}
                            className="flex items-center gap-3 cursor-pointer group select-none text-xs text-neutral-300 hover:text-white"
                          >
                            <input
                              type="radio"
                              name="bothDirectionsStyle"
                              checked={bothDirectionsStyle === style.id}
                              onChange={() => setBothDirectionsStyle(style.id as BothDirectionsStyle)}
                              className="w-3.5 h-3.5 text-blue-500 bg-[#282830] border-neutral-600 focus:ring-0 cursor-pointer accent-blue-500"
                            />
                            <span>{style.label}</span>
                          </label>
                        ))}
                      </div>

                      <p className="text-[11px] text-neutral-400">
                        {bothDirectionsStyle === "separateSpeeds" &&
                          "Display download and upload speeds independently."}
                        {bothDirectionsStyle === "combinedArrows" &&
                          "Display both direction arrows with the speed of the currently dominant direction."}
                        {bothDirectionsStyle === "withoutArrows" &&
                          "Display download and upload speeds independently with compact text labels."}
                      </p>

                      {/* In-Settings Preview Container */}
                      <div className="p-3 bg-[#131317] rounded-xl border border-white/[0.08] flex items-center justify-between text-xs">
                        <span className="text-neutral-400 text-[11px]">Preview:</span>
                        <div className="font-mono px-3 py-1 bg-black/40 rounded-lg border border-white/[0.06]">
                          {renderMenuBarOutput()}
                        </div>
                      </div>
                    </div>
                  )}

                  {displayMode === "singleDirectionManual" && (
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <label className="text-xs font-medium text-neutral-300">
                          Selected Direction
                        </label>
                        <div className="flex items-center gap-4">
                          {[
                            { id: "download", label: "Download" },
                            { id: "upload", label: "Upload" },
                          ].map((dir) => (
                            <label
                              key={dir.id}
                              className="flex items-center gap-2 cursor-pointer select-none text-xs text-neutral-300 hover:text-white"
                            >
                              <input
                                type="radio"
                                name="manualDirection"
                                checked={manualDirection === dir.id}
                                onChange={() => setManualDirection(dir.id as NetworkDirection)}
                                className="w-3.5 h-3.5 text-blue-500 bg-[#282830] border-neutral-600 focus:ring-0 cursor-pointer accent-blue-500"
                              />
                              <span>{dir.label}</span>
                            </label>
                          ))}
                        </div>
                      </div>

                      <div className="space-y-2">
                        <label className="text-xs font-medium text-neutral-300">
                          Arrow Visibility
                        </label>
                        <div className="flex items-center gap-4">
                          {[
                            { id: "withArrow", label: "With Arrow" },
                            { id: "withoutArrows", label: "Without Arrows" },
                          ].map((arrowOpt) => (
                            <label
                              key={arrowOpt.id}
                              className="flex items-center gap-2 cursor-pointer select-none text-xs text-neutral-300 hover:text-white"
                            >
                              <input
                                type="radio"
                                name="singleDirectionArrowStyle"
                                checked={singleDirectionArrowStyle === arrowOpt.id}
                                onChange={() =>
                                  setSingleDirectionArrowStyle(arrowOpt.id as SingleDirectionArrowStyle)
                                }
                                className="w-3.5 h-3.5 text-blue-500 bg-[#282830] border-neutral-600 focus:ring-0 cursor-pointer accent-blue-500"
                              />
                              <span>{arrowOpt.label}</span>
                            </label>
                          ))}
                        </div>
                      </div>

                      <p className="text-[11px] text-neutral-400">
                        Continuously display {manualDirection} speed. Dominant direction switching will not override this.
                      </p>

                      <div className="p-3 bg-[#131317] rounded-xl border border-white/[0.08] flex items-center justify-between text-xs">
                        <span className="text-neutral-400 text-[11px]">Preview:</span>
                        <div className="font-mono px-3 py-1 bg-black/40 rounded-lg border border-white/[0.06]">
                          {renderMenuBarOutput()}
                        </div>
                      </div>
                    </div>
                  )}

                  {displayMode === "singleDirectionAutomatic" && (
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <label className="text-xs font-medium text-neutral-300">
                          Arrow Visibility
                        </label>
                        <div className="flex items-center gap-4">
                          {[
                            { id: "withArrow", label: "With Arrow" },
                            { id: "withoutArrows", label: "Without Arrows" },
                          ].map((arrowOpt) => (
                            <label
                              key={arrowOpt.id}
                              className="flex items-center gap-2 cursor-pointer select-none text-xs text-neutral-300 hover:text-white"
                            >
                              <input
                                type="radio"
                                name="autoArrowStyle"
                                checked={singleDirectionArrowStyle === arrowOpt.id}
                                onChange={() =>
                                  setSingleDirectionArrowStyle(arrowOpt.id as SingleDirectionArrowStyle)
                                }
                                className="w-3.5 h-3.5 text-blue-500 bg-[#282830] border-neutral-600 focus:ring-0 cursor-pointer accent-blue-500"
                              />
                              <span>{arrowOpt.label}</span>
                            </label>
                          ))}
                        </div>
                      </div>

                      <p className="text-[11px] text-neutral-400">
                        Automatically displays the direction currently carrying dominant traffic using 3-factor hysteresis switching.
                      </p>

                      <div className="p-3 bg-[#131317] rounded-xl border border-white/[0.08] flex items-center justify-between text-xs">
                        <span className="text-neutral-400 text-[11px]">Preview:</span>
                        <div className="font-mono px-3 py-1 bg-black/40 rounded-lg border border-white/[0.06]">
                          {renderMenuBarOutput()}
                        </div>
                      </div>
                    </div>
                  )}
                </div>

                {/* General Section (Launch at Login) */}
                <div className="pt-4 border-t border-white/[0.08] space-y-2">
                  <label className="text-xs font-semibold text-neutral-200 uppercase tracking-wider block">
                    General
                  </label>
                  <label className="flex items-center gap-2.5 cursor-pointer text-xs text-neutral-200 hover:text-white select-none">
                    <input
                      type="checkbox"
                      checked={launchAtLogin}
                      onChange={(e) => setLaunchAtLogin(e.target.checked)}
                      className="w-4 h-4 rounded text-blue-500 bg-[#282830] border-neutral-600 focus:ring-0 cursor-pointer accent-blue-500"
                    />
                    <span className="font-medium">Launch at Login</span>
                  </label>
                  <p className="text-[11px] text-neutral-400 pl-6">
                    Automatically start ARRY Network Counter when you log in to macOS.
                  </p>
                  {launchAtLogin && (
                    <div className="flex items-center gap-1.5 pl-6 pt-1 text-[11px] text-emerald-400">
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      <span>Registered with macOS login items</span>
                    </div>
                  )}
                </div>
              </div>
            )}

            {activeTab === "documentation" && (
              <div className="space-y-4 animate-in fade-in duration-200">
                <div className="space-y-1">
                  <h4 className="text-sm font-semibold text-white">Offline Documentation</h4>
                  <p className="text-xs text-neutral-400">
                    All guides and legal disclosures are bundled locally and fully accessible without an internet connection.
                  </p>
                </div>

                <div className="rounded-xl bg-[#202026]/90 border border-white/[0.08] divide-y divide-white/[0.06] overflow-hidden">
                  {[
                    {
                      title: "Setup & Installation Guide",
                      desc: "System requirements, DMG install, Gatekeeper, and login items",
                      route: "/anc/install",
                      icon: RefreshCw,
                    },
                    {
                      title: "User & Operations Guide",
                      desc: "Display modes, direction switching, SI units, and limitations",
                      route: "/anc/guide",
                      icon: BookOpen,
                    },
                    {
                      title: "Terms and Conditions",
                      desc: "Software license, permitted usage, disclaimers, and warranty",
                      route: "/anc/terms",
                      icon: FileText,
                    },
                    {
                      title: "Privacy Policy",
                      desc: "Local storage, kernel counters, and zero-telemetry audit",
                      route: "/anc/privacy",
                      icon: FileText,
                    },
                  ].map((doc, idx) => {
                    const IconComponent = doc.icon;
                    return (
                      <Link
                        key={idx}
                        href={doc.route}
                        className="flex items-center justify-between p-3.5 hover:bg-white/[0.04] transition-all group"
                      >
                        <div className="flex items-center gap-3.5">
                          <div className="w-7 h-7 rounded-lg bg-blue-500/10 flex items-center justify-center shrink-0">
                            <IconComponent className="w-4 h-4 text-[#007AFF]" />
                          </div>
                          <div>
                            <div className="text-xs font-medium text-white group-hover:text-blue-400 transition-colors">
                              {doc.title}
                            </div>
                            <div className="text-[11px] text-neutral-400">
                              {doc.desc}
                            </div>
                          </div>
                        </div>
                        <ChevronRight className="w-4 h-4 text-neutral-500 group-hover:text-white transition-colors" />
                      </Link>
                    );
                  })}
                </div>
              </div>
            )}

            {activeTab === "about" && (
              <div className="text-center py-4 space-y-3 animate-in fade-in duration-200">
                <div className="relative w-20 h-20 mx-auto rounded-2xl overflow-hidden border border-white/10 shadow-[0_8px_24px_rgba(48,184,107,0.2)]">
                  <Image
                    src="/images/app-icon.png"
                    alt="ANC App Icon"
                    fill
                    sizes="80px"
                    className="object-cover"
                  />
                </div>

                <div className="space-y-0.5">
                  <h3 className="text-base font-bold text-white tracking-tight">
                    ARRY Network Counter
                  </h3>
                  <p className="text-xs text-neutral-400">
                    (ANC)
                  </p>
                  <p className="text-xs text-neutral-400 font-mono">
                    Version 1.0.0 (Build 1)
                  </p>
                </div>

                <div className="max-w-xs mx-auto text-xs text-neutral-300 space-y-1 pt-1">
                  <p className="font-semibold text-white">Designed and engineered by ARRRY</p>
                  <p className="text-[11px] text-neutral-400 leading-relaxed">
                    A lightweight, privacy-focused native macOS menu-bar utility for real-time network throughput monitoring.
                  </p>
                </div>

                <div className="w-full max-w-xs mx-auto border-t border-white/[0.08] my-2" />

                <div className="space-y-1 text-xs text-[#007AFF]">
                  <div className="flex items-center justify-center gap-2">
                    <Link href="/anc/terms" className="hover:underline">Terms & Conditions</Link>
                    <span className="text-neutral-500">•</span>
                    <Link href="/anc/privacy" className="hover:underline">Privacy Policy</Link>
                  </div>
                  <div className="flex items-center justify-center gap-2">
                    <Link href="/anc/install" className="hover:underline">Setup Guide</Link>
                    <span className="text-neutral-500">•</span>
                    <Link href="/anc/guide" className="hover:underline">Usage Guide</Link>
                  </div>
                </div>

                <div className="text-[11px] text-neutral-500 pt-3 space-y-0.5">
                  <div>Copyright © 2026 ARRRY. All rights reserved.</div>
                  <div>Universal Binary • macOS 13.0+</div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* RIGHT PANEL: Live macOS Menu Bar Preview & Simulation Engine (col-span-5) */}
        <div className="lg:col-span-5 space-y-6">
          {/* macOS Desktop & Menu Bar Simulation Window */}
          <div className="w-full bg-[#0D0D12]/90 backdrop-blur-2xl rounded-2xl border border-white/[0.12] shadow-[0_20px_50px_rgba(0,0,0,0.6),inset_0_1px_0_0_rgba(255,255,255,0.12)] overflow-hidden">
            {/* Realistic macOS Menu Bar Top Strip */}
            <div className="relative px-3 py-2 bg-black/60 backdrop-blur-xl border-b border-white/[0.08] flex items-center justify-between text-neutral-300 text-xs select-none">
              {/* Leading side: Apple + App menus */}
              <div className="flex items-center space-x-3.5 text-[11px] font-normal">
                <span className="text-white text-sm font-serif"></span>
                <span className="font-semibold text-white">Finder</span>
                <span className="hidden sm:inline text-neutral-300">File</span>
                <span className="hidden sm:inline text-neutral-300">Edit</span>
                <span className="hidden sm:inline text-neutral-300">View</span>
                <span className="hidden sm:inline text-neutral-300">Go</span>
                <span className="hidden sm:inline text-neutral-300">Window</span>
                <span className="hidden sm:inline text-neutral-300">Help</span>
              </div>

              {/* Trailing side: ANC Status Item + macOS status icons */}
              <div className="flex items-center space-x-3 relative">
                {/* ANC LIVE MENU BAR STATUS ITEM (Clickable!) */}
                <button
                  onClick={() => setMenuBarDropdownOpen(!menuBarDropdownOpen)}
                  className={`px-2 py-0.5 rounded-md transition-all duration-150 flex items-center gap-1 focus:outline-none ${
                    menuBarDropdownOpen
                      ? "bg-blue-600 text-white shadow-sm"
                      : "hover:bg-white/10"
                  }`}
                  title="Click to toggle ANC menu bar dropdown"
                >
                  {renderMenuBarOutput()}
                </button>

                {/* Simulated macOS Menu Dropdown */}
                {menuBarDropdownOpen && (
                  <div className="absolute right-12 top-8 z-30 w-56 bg-[#202026]/95 backdrop-blur-2xl rounded-xl border border-white/15 shadow-[0_12px_40px_rgba(0,0,0,0.8)] py-1.5 text-xs text-neutral-200 animate-in fade-in zoom-in-95 duration-150">
                    <div className="px-3 py-1 text-[11px] text-neutral-400 font-medium">
                      Active: en0 (Wi-Fi 6)
                    </div>
                    <div className="px-3 py-1 text-[11px] text-neutral-400">
                      Sampling: 1.0s Monotonic
                    </div>
                    <div className="my-1 border-t border-white/10" />
                    <button
                      onClick={() => {
                        setActiveTab("preferences");
                        setMenuBarDropdownOpen(false);
                      }}
                      className="w-full px-3 py-1.5 text-left hover:bg-blue-600 hover:text-white flex items-center justify-between"
                    >
                      <span>Settings…</span>
                      <span className="text-[10px] text-neutral-400">⌘,</span>
                    </button>
                    <button
                      onClick={() => {
                        setActiveTab("documentation");
                        setMenuBarDropdownOpen(false);
                      }}
                      className="w-full px-3 py-1.5 text-left hover:bg-blue-600 hover:text-white"
                    >
                      Documentation…
                    </button>
                    <button
                      onClick={() => {
                        setActiveTab("about");
                        setMenuBarDropdownOpen(false);
                      }}
                      className="w-full px-3 py-1.5 text-left hover:bg-blue-600 hover:text-white"
                    >
                      About ARRY Network Counter
                    </button>
                    <div className="my-1 border-t border-white/10" />
                    <div className="px-3 py-1.5 text-neutral-400 hover:bg-white/5 cursor-not-allowed">
                      Quit ARRY Network Counter ⌘Q
                    </div>
                  </div>
                )}

                {/* Standard macOS Status Icons */}
                <div className="flex items-center space-x-2 text-neutral-400 text-xs">
                  <Wifi className="w-3.5 h-3.5 text-neutral-300" />
                  <Battery className="w-3.5 h-3.5 text-neutral-300" />
                  <Sliders className="w-3 h-3 text-neutral-300" />
                  <Search className="w-3 h-3 text-neutral-300" />
                  <span className="text-[11px] font-medium text-neutral-200 font-mono">
                    Sun 11:32 AM
                  </span>
                </div>
              </div>
            </div>

            {/* Desktop Wallpaper Mockup below menu bar */}
            <div className="p-6 relative bg-gradient-to-b from-[#101016] to-[#0A0A0E] min-h-[220px] flex flex-col justify-between">
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <div className="text-xs font-semibold text-neutral-300">
                    Live macOS Menu Bar Output
                  </div>
                  <div className="text-[11px] text-neutral-500">
                    Click the throughput speed in the menu bar above to inspect its native context menu.
                  </div>
                </div>
                <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-white/5 border border-white/10 text-neutral-400">
                  macOS Sequoia
                </span>
              </div>

              {/* Magnified Output Showcase Card */}
              <div className="p-4 rounded-xl bg-black/60 border border-white/10 backdrop-blur-md shadow-inner space-y-2">
                <div className="flex items-center justify-between text-[11px] text-neutral-400">
                  <span>Current Menu Bar Display</span>
                  <span className="font-mono text-emerald-400 text-[10px]">Active</span>
                </div>
                <div className="text-xl sm:text-2xl font-mono py-1 flex items-center justify-center bg-white/[0.02] rounded-lg border border-white/5">
                  {renderMenuBarOutput()}
                </div>
                <div className="flex items-center justify-between text-[10px] text-neutral-500 pt-1 border-t border-white/5">
                  <span>Downlink: <strong className="text-neutral-300 font-mono">{dlFormatted.displayString}</strong></span>
                  <span>Uplink: <strong className="text-neutral-300 font-mono">{ulFormatted.displayString}</strong></span>
                </div>
              </div>
            </div>
          </div>

          {/* SIMULATION CONTROLS TOOLBAR */}
          <div className="p-5 bg-[#121217]/90 rounded-2xl border border-white/[0.10] shadow-lg space-y-4">
            <div className="flex items-center justify-between">
              <h4 className="text-xs font-semibold text-white uppercase tracking-wider flex items-center gap-2">
                <Sparkles className="w-3.5 h-3.5 text-emerald-400" />
                Network Traffic Simulator
              </h4>
              <button
                onClick={() => applyPreset(PRESETS[0])}
                className="text-[11px] text-neutral-400 hover:text-white flex items-center gap-1 transition-colors"
                title="Reset simulation to default"
              >
                <RefreshCw className="w-3 h-3" />
                Reset
              </button>
            </div>

            {/* Presets Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
              {PRESETS.map((preset) => (
                <button
                  key={preset.name}
                  onClick={() => applyPreset(preset)}
                  className={`px-3 py-2 rounded-xl text-left text-xs transition-all border ${
                    activePreset === preset.name
                      ? "bg-emerald-500/10 border-emerald-500/30 text-white font-medium shadow-sm"
                      : "bg-white/[0.03] border-white/[0.06] text-neutral-400 hover:text-white hover:bg-white/[0.06]"
                  }`}
                >
                  <div className="font-semibold text-[11px] truncate">{preset.label}</div>
                  <div className="text-[10px] text-neutral-500 font-mono truncate mt-0.5">
                    {preset.name === "idle" ? "0 KB/s" : preset.name}
                  </div>
                </button>
              ))}
            </div>

            {/* Manual Sliders for Custom Speeds */}
            <div className="space-y-3 pt-2 border-t border-white/[0.08]">
              {/* Download Speed Slider */}
              <div className="space-y-1">
                <div className="flex justify-between text-xs">
                  <span className="text-neutral-400 flex items-center gap-1.5">
                    <span style={{ color: DOWNLOAD_COLOR }} className="font-bold">↓</span>
                    Download Throughput:
                  </span>
                  <span className="font-mono text-emerald-400 font-semibold">{dlFormatted.displayString}</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="50000000"
                  step="50000"
                  value={downloadBps}
                  onChange={(e) => {
                    setDownloadBps(Number(e.target.value));
                    setActivePreset("custom");
                  }}
                  className="w-full h-1.5 bg-neutral-800 rounded-lg appearance-none cursor-pointer accent-emerald-500"
                />
              </div>

              {/* Upload Speed Slider */}
              <div className="space-y-1">
                <div className="flex justify-between text-xs">
                  <span className="text-neutral-400 flex items-center gap-1.5">
                    <span style={{ color: UPLOAD_COLOR }} className="font-bold">↑</span>
                    Upload Throughput:
                  </span>
                  <span className="font-mono text-sky-400 font-semibold">{ulFormatted.displayString}</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="50000000"
                  step="50000"
                  value={uploadBps}
                  onChange={(e) => {
                    setUploadBps(Number(e.target.value));
                    setActivePreset("custom");
                  }}
                  className="w-full h-1.5 bg-neutral-800 rounded-lg appearance-none cursor-pointer accent-sky-500"
                />
              </div>
            </div>

            {/* Direction Status & Stability Output */}
            <div className="p-3 bg-black/40 rounded-xl border border-white/[0.06] text-[11px] space-y-1 font-mono">
              <div className="text-neutral-400 flex items-center justify-between">
                <span>Active Direction:</span>
                <span className={`font-semibold capitalize ${dominantDirection === "download" ? "text-emerald-400" : "text-sky-400"}`}>
                  {dominantDirection} {dominantDirection === "download" ? "↓" : "↑"}
                </span>
              </div>
              <div className="text-neutral-400 text-[10px] pt-1 border-t border-white/5 font-sans">
                Smart anti-flicker stability ensures smooth direction switching without menu-bar jitter.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
