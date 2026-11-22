import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Formats a raw byte-per-second value following ARRY Network Counter's
 * exact SI Decimal base-1000 scaling rules (ADR-014):
 * - < 1,000: B/s (0 is formatted as "0 KB/s")
 * - 1,000 .. < 1,000,000: KB/s
 * - 1,000,000 .. < 1,000,000,000: MB/s
 * - >= 1,000,000,000: GB/s
 * - Up to 2 decimal places with trailing zeros stripped (e.g. 1.5 MB/s instead of 1.50 MB/s)
 */
export function formatSpeed(bytesPerSecond: number): {
  value: number;
  unit: string;
  formattedValue: string;
  displayString: string;
} {
  if (bytesPerSecond <= 0) {
    return {
      value: 0,
      unit: "KB/s",
      formattedValue: "0",
      displayString: "0 KB/s",
    };
  }

  let unit = "B/s";
  let scaled = bytesPerSecond;

  if (bytesPerSecond >= 1_000_000_000) {
    unit = "GB/s";
    scaled = bytesPerSecond / 1_000_000_000;
  } else if (bytesPerSecond >= 1_000_000) {
    unit = "MB/s";
    scaled = bytesPerSecond / 1_000_000;
  } else if (bytesPerSecond >= 1_000) {
    unit = "KB/s";
    scaled = bytesPerSecond / 1_000;
  } else {
    unit = "B/s";
    scaled = bytesPerSecond;
  }

  // Format to 2 decimal places and strip trailing zeros
  let formatted = scaled.toFixed(2);
  if (formatted.includes(".")) {
    formatted = formatted.replace(/\.?0+$/, "");
  }

  return {
    value: scaled,
    unit,
    formattedValue: formatted,
    displayString: `${formatted} ${unit}`,
  };
}
