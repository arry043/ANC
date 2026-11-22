import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
  async rewrites() {
    return [
      { source: "/download", destination: "/anc/download" },
      { source: "/download/latest", destination: "/anc/download/latest" },
      { source: "/install", destination: "/anc/install" },
      { source: "/features", destination: "/anc/features" },
      { source: "/guide", destination: "/anc/guide" },
      { source: "/privacy", destination: "/anc/privacy" },
      { source: "/terms", destination: "/anc/terms" },
      { source: "/changelog", destination: "/anc/changelog" },
      { source: "/faq", destination: "/anc/faq" },
    ];
  },
};

export default nextConfig;
