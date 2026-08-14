import React from "react";

export default function JewelArt({ type, ...props }) {
  const common = { fill: "none", stroke: "currentColor", strokeWidth: 1.6, strokeLinecap: "round", strokeLinejoin: "round" };
  switch (type) {
    case "signet":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <circle cx="50" cy="64" r="24" {...common} />
          <rect x="33" y="14" width="34" height="26" rx="7" {...common} />
        </svg>
      );
    case "ringThin":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <circle cx="50" cy="54" r="25" {...common} />
          <circle cx="50" cy="54" r="18" {...common} />
        </svg>
      );
    case "chain":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <path d="M20 18 Q35 30 20 42 Q5 54 20 66 Q35 78 24 90" {...common} />
          <ellipse cx="60" cy="24" rx="9" ry="13" transform="rotate(20 60 24)" {...common} />
          <ellipse cx="66" cy="46" rx="9" ry="13" transform="rotate(-15 66 46)" {...common} />
          <ellipse cx="58" cy="68" rx="9" ry="13" transform="rotate(20 58 68)" {...common} />
        </svg>
      );
    case "pendant":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <path d="M50 10 Q20 30 50 46 Q80 30 50 10" {...common} />
          <path d="M50 46 L50 62" {...common} />
          <path d="M50 62 C36 62 32 78 50 92 C68 78 64 62 50 62 Z" {...common} />
        </svg>
      );
    case "drop":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <circle cx="50" cy="16" r="7" {...common} />
          <path d="M50 23 L50 36" {...common} />
          <path d="M50 36 C30 36 26 60 50 88 C74 60 70 36 50 36 Z" {...common} />
        </svg>
      );
    case "hoop":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <path d="M46 12 h8" {...common} />
          <circle cx="50" cy="52" r="34" {...common} />
        </svg>
      );
    case "stud":
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <path d="M50 14 L70 46 L50 78 L30 46 Z" {...common} />
          <path d="M30 46 H70" {...common} />
        </svg>
      );
    case "ring":
    default:
      return (
        <svg viewBox="0 0 100 100" {...props}>
          <circle cx="50" cy="60" r="28" {...common} />
          <path d="M50 30 L59 18 L68 30 L59 22 Z" {...common} />
        </svg>
      );
  }
}
