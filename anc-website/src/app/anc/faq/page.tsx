"use client";

import React, { useState } from "react";
import Link from "next/link";
import { faqItems } from "@/data/faq";
import { HelpCircle, ChevronDown, Sparkles, MessageCircle } from "lucide-react";

export default function FAQPage() {
  const [selectedCategory, setSelectedCategory] = useState<string>("all");
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const categories = [
    { id: "all", label: "All Questions" },
    { id: "general", label: "General" },
    { id: "features", label: "Display & Modes" },
    { id: "technical", label: "Technical & Units" },
    { id: "privacy", label: "Privacy & Data" },
    { id: "troubleshooting", label: "Troubleshooting" },
  ];

  const filteredFaqs =
    selectedCategory === "all"
      ? faqItems
      : faqItems.filter((item) => item.category === selectedCategory);

  const toggleAccordion = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <div className="py-28 lg:py-36 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-emerald-500/10 blur-[140px] pointer-events-none rounded-full" />

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-12">
        {/* Header */}
        <div className="text-center max-w-2xl mx-auto space-y-4">
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-mono text-neutral-300">
            <HelpCircle className="w-3.5 h-3.5 text-emerald-400" />
            <span>KNOWLEDGE BASE & SUPPORT</span>
          </div>
          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Frequently Asked Questions
          </h1>
          <p className="text-sm sm:text-base text-neutral-400 leading-relaxed">
            Find immediate, accurate answers to common questions about ARRY Network Counter&apos;s features, compatibility, architecture, and operation.
          </p>
        </div>

        {/* Category Pills Filter */}
        <div className="flex flex-wrap items-center justify-center gap-2">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(cat.id)}
              className={`px-4 py-2 rounded-xl text-xs font-medium transition-all ${
                selectedCategory === cat.id
                  ? "bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 shadow-sm"
                  : "bg-white/[0.03] border border-white/[0.06] text-neutral-400 hover:text-white hover:bg-white/[0.06]"
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* FAQ Accordion List */}
        <div className="space-y-3">
          {filteredFaqs.map((faq, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div
                key={idx}
                className="rounded-2xl bg-[#0F0F14]/90 backdrop-blur-xl border border-white/[0.08] overflow-hidden transition-all duration-200"
              >
                <button
                  onClick={() => toggleAccordion(idx)}
                  className="w-full p-5 sm:p-6 text-left flex items-center justify-between gap-4 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500"
                  aria-expanded={isOpen}
                >
                  <span className="text-sm sm:text-base font-semibold text-white tracking-tight">
                    {faq.question}
                  </span>
                  <div
                    className={`w-7 h-7 rounded-lg bg-white/[0.04] flex items-center justify-center shrink-0 text-neutral-400 transition-transform duration-200 ${
                      isOpen ? "rotate-180 text-emerald-400" : ""
                    }`}
                  >
                    <ChevronDown className="w-4 h-4" />
                  </div>
                </button>

                {isOpen && (
                  <div className="px-5 pb-6 sm:px-6 text-xs sm:text-sm text-neutral-300 leading-relaxed border-t border-white/[0.06] pt-4 animate-in fade-in duration-200">
                    <p>{faq.answer}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Contact Note */}
        <div className="p-6 rounded-2xl bg-white/[0.02] border border-white/[0.06] text-center space-y-2">
          <h4 className="text-sm font-semibold text-white">Have a question not listed here?</h4>
          <p className="text-xs text-neutral-400 max-w-md mx-auto">
            Check the bundled in-app offline documentation or submit an inquiry through the official ARRRY project repository.
          </p>
        </div>
      </div>
    </div>
  );
}
