import React from "react";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";

export default function Craft() {
  return (
    <section id="craft" style={{ background: COLORS.surfaceStrong, color: COLORS.textOnStrong, padding: "120px 0", position: "relative", overflow: "hidden" }} className="px-4 sm:px-6 md:px-10">
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: COLORS.craftGlow,
        }}
      />
      <div style={{ maxWidth: 1240, margin: "0 auto", position: "relative" }}>
        <div className="flex flex-col md:flex-row" style={{ gap: 36, alignItems: "center" }}>
          <Reveal className="flex-1">
            <p style={{ fontSize: 13, letterSpacing: "0.2em", textTransform: "uppercase", color: COLORS.gold, marginBottom: 18 }}>
              Where the metal comes from
            </p>
            <h2 style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(30px, 4vw, 48px)", lineHeight: 1.1, marginBottom: 24 }}>
              We haven't mined a single gram since 2019.
            </h2>
            <p style={{ fontSize: 16, lineHeight: 1.75, color: COLORS.textOnStrongMuted, maxWidth: 480 }}>
              Old rings that no longer fit. Industrial gold scrap. Coins pulled
              from drawers. It's all refined in a small workshop two floors
              below ours, then cast into the pieces you see here — the same
              metal, remembering a different shape.
            </p>
          </Reveal>
          <Reveal delay={150} className="flex-1" style={{ textAlign: "center" }}>
            <div style={{ fontFamily: FONT_DISPLAY, fontStyle: "italic", fontSize: "clamp(80px, 12vw, 160px)", lineHeight: 1, color: COLORS.gold }}>
              92.5%
            </div>
            <p style={{ fontSize: 14, letterSpacing: "0.05em", color: COLORS.textOnStrongMuted, marginTop: 8 }}>
              of the precious metal we use each year is reclaimed, not newly mined
            </p>
          </Reveal>
        </div>
      </div>
    </section>
  );
}
