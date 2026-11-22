import React from "react";
import { HeroSection } from "@/components/hero/HeroSection";
import { FeaturesShowcase } from "@/components/features/FeaturesShowcase";
import { VideoTour } from "@/components/hero/VideoTour";
import { TechSpecsSection } from "@/components/home/TechSpecsSection";
import { FinalDownloadCTA } from "@/components/home/FinalDownloadCTA";

export default function LandingPage() {
  return (
    <div className="relative">
      <HeroSection />
      <FeaturesShowcase />
      <VideoTour />
      <TechSpecsSection />
      <FinalDownloadCTA />
    </div>
  );
}
