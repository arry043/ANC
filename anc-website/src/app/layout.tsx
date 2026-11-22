import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL("https://anc.arrry.in"),
  title: {
    default: "ARRY Network Counter — Real-Time macOS Network Monitor",
    template: "%s · ARRY Network Counter",
  },
  description:
    "Monitor real-time download and upload speeds directly from your macOS menu bar with ARRY Network Counter. Lightweight, native Swift 6, and zero telemetry.",
  keywords: [
    "macOS network monitor",
    "menu bar network speed",
    "upload download speed",
    "ARRY Network Counter",
    "ANC",
    "Apple Silicon network counter",
    "native Mac utility",
  ],
  authors: [{ name: "ARRRY", url: "https://arrry.in" }],
  creator: "ARRRY",
  publisher: "ARRRY",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://anc.arrry.in",
    siteName: "ARRY Network Counter",
    title: "ARRY Network Counter — Real-Time macOS Network Monitor",
    description:
      "Monitor download and upload speeds directly from your macOS menu bar with ARRY Network Counter. Lightweight, native, and always within reach.",
    images: [
      {
        url: "/images/app-icon.png",
        width: 1024,
        height: 1024,
        alt: "ARRY Network Counter App Icon",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ARRY Network Counter — Real-Time macOS Network Monitor",
    description:
      "Monitor download and upload speeds directly from your macOS menu bar with ARRY Network Counter.",
    images: ["/images/app-icon.png"],
  },
  icons: {
    icon: "/images/app-icon-32.png",
    apple: "/images/app-icon-512.png",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased dark`}
    >
      <body className="min-h-full flex flex-col bg-[#060608] text-[#F2F2F5] selection:bg-emerald-500/30 selection:text-emerald-200">
        <Navbar />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
