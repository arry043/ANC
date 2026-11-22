import { NextResponse } from "next/server";
import { latestRelease } from "@/data/releases";

export async function GET() {
  return NextResponse.redirect(latestRelease.downloadUrl, {
    status: 307,
    headers: {
      "Cache-Control": "no-cache, no-store, must-revalidate",
    },
  });
}
