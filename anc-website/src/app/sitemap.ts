import { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://anc.arrry.in";
  const routes = [
    "",
    "/anc",
    "/anc/download",
    "/anc/install",
    "/anc/features",
    "/anc/guide",
    "/anc/privacy",
    "/anc/terms",
    "/anc/changelog",
    "/anc/faq",
  ];

  return routes.map((route) => ({
    url: `${baseUrl}${route}`,
    lastModified: new Date(),
    changeFrequency: route === "" || route === "/anc" ? "weekly" : "monthly",
    priority: route === "" || route === "/anc" ? 1.0 : route.includes("download") ? 0.9 : 0.7,
  }));
}
