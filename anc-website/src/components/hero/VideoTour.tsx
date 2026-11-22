"use client";

import React, { useState, useRef } from "react";
import Image from "next/image";
import { Play, Pause, Volume2, VolumeX, Maximize2, RotateCcw } from "lucide-react";

export function VideoTour() {
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(true);
  const videoRef = useRef<HTMLVideoElement>(null);

  const togglePlay = () => {
    if (!videoRef.current) return;
    if (isPlaying) {
      videoRef.current.pause();
      setIsPlaying(false);
    } else {
      videoRef.current.play();
      setIsPlaying(true);
    }
  };

  const toggleMute = () => {
    if (!videoRef.current) return;
    videoRef.current.muted = !isMuted;
    setIsMuted(!isMuted);
  };

  const handleFullscreen = () => {
    if (!videoRef.current) return;
    if (videoRef.current.requestFullscreen) {
      videoRef.current.requestFullscreen();
    }
  };

  const restartVideo = () => {
    if (!videoRef.current) return;
    videoRef.current.currentTime = 0;
    videoRef.current.play();
    setIsPlaying(true);
  };

  return (
    <section className="relative py-20 lg:py-28 overflow-hidden bg-[#07070A] border-t border-white/[0.08]">
      {/* Background ambient lighting */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[400px] bg-emerald-500/5 blur-[120px] rounded-full pointer-events-none" />

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="text-center max-w-2xl mx-auto mb-12 space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <span>OFFICIAL PRODUCT DEMONSTRATION</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">
            See ANC in Action
          </h2>
          <p className="text-neutral-400 text-sm sm:text-base leading-relaxed">
            Watch the live macOS desktop recording showing real-time menu-bar throughput, dynamic direction switching, and native Settings operation.
          </p>
        </div>

        {/* Video Player in Premium macOS Window Frame */}
        <div className="relative rounded-2xl bg-[#14141A] border border-white/[0.12] shadow-[0_25px_60px_rgba(0,0,0,0.8),inset_0_1px_0_0_rgba(255,255,255,0.15)] overflow-hidden group">
          {/* macOS Title Bar */}
          <div className="px-4 py-3 bg-[#1C1C24] border-b border-white/[0.08] flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <span className="w-3 h-3 rounded-full bg-[#FF5F56] border border-[#E0443E]/50" />
              <span className="w-3 h-3 rounded-full bg-[#FFBD2E] border border-[#DEA123]/50" />
              <span className="w-3 h-3 rounded-full bg-[#27C93F] border border-[#1AAB29]/50" />
            </div>
            <div className="text-xs font-medium text-neutral-400 tracking-tight">
              Screen Recording — ARRY Network Counter v1.0.0
            </div>
            <div className="flex items-center space-x-2 text-neutral-400 text-xs">
              <span className="font-mono text-[11px] text-neutral-500">1080p · macOS</span>
            </div>
          </div>

          {/* Video Container */}
          <div className="relative aspect-[16/10] bg-black flex items-center justify-center overflow-hidden">
            <video
              ref={videoRef}
              src="/video/anc-tour.mp4"
              poster="/images/video-poster.jpg"
              preload="none"
              playsInline
              muted={isMuted}
              onPlay={() => setIsPlaying(true)}
              onPause={() => setIsPlaying(false)}
              onEnded={() => setIsPlaying(false)}
              className="w-full h-full object-contain"
            />

            {/* Big Center Play Button Overlay (when paused) */}
            {!isPlaying && (
              <button
                onClick={togglePlay}
                className="absolute inset-0 flex items-center justify-center bg-black/40 backdrop-blur-[2px] transition-all group-hover:bg-black/30"
                aria-label="Play product recording"
              >
                <div className="w-20 h-20 rounded-full bg-emerald-500/90 text-white flex items-center justify-center shadow-[0_0_30px_rgba(48,184,107,0.5)] group-hover:scale-110 transition-transform duration-200 pl-1">
                  <Play className="w-9 h-9 fill-current" />
                </div>
              </button>
            )}

            {/* Video Controls Bar Overlay */}
            <div className="absolute bottom-0 inset-x-0 p-4 bg-gradient-to-t from-black/80 via-black/40 to-transparent flex items-center justify-between opacity-0 group-hover:opacity-100 transition-opacity duration-200">
              <div className="flex items-center space-x-3">
                <button
                  onClick={togglePlay}
                  className="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors"
                  aria-label={isPlaying ? "Pause" : "Play"}
                >
                  {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 fill-current" />}
                </button>
                <button
                  onClick={restartVideo}
                  className="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors"
                  aria-label="Restart"
                >
                  <RotateCcw className="w-4 h-4" />
                </button>
                <button
                  onClick={toggleMute}
                  className="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors"
                  aria-label={isMuted ? "Unmute" : "Mute"}
                >
                  {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
                </button>
              </div>

              <div className="flex items-center space-x-3">
                <span className="text-[11px] text-neutral-400 font-mono">
                  ANC macOS Walkthrough
                </span>
                <button
                  onClick={handleFullscreen}
                  className="p-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors"
                  aria-label="Fullscreen"
                >
                  <Maximize2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
