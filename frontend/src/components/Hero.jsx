import React from "react";
import { ChevronDown, ArrowRight } from "lucide-react";

import { COLORS, FONT_DISPLAY } from "../constants/theme";

export default function Hero({ scrollTo }) {
  return (
    <section id="top" style={{ position: "relative", minHeight: "100svh", background: COLORS.surfaceStrong, color: COLORS.textOnStrong, overflow: "hidden" }}>
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: COLORS.heroGlow,
        }}
      />
   <div
  className="hero-art"
  style={{
    position: "absolute",
    right: "2%",
    top: "50%",
    transform: "translateY(-50%)",
    width: "40%",
    maxWidth: 500,
    zIndex: 1,
  }}
>
  <img
    src="/ring-hero.png"
    alt="Gold ring"
    style={{
      width: "100%",
      height: "auto",
      objectFit: "contain",
      display: "block",
    }}
  />
</div>

      <div style={{ position: "relative", maxWidth: 1240, margin: "0 auto" }} className="px-4 sm:px-6 md:px-10">
        <div
          style={{
            minHeight: "100svh",
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            paddingTop: "clamp(108px, 24vw, 140px)",
            paddingBottom: "clamp(72px, 12vw, 96px)",
          }}
        >
          <p style={{ fontSize: 13, letterSpacing: "0.22em", textTransform: "uppercase", color: COLORS.gold, marginBottom: 22 }}>
            Fine jewelry, cast from reclaimed metal
          </p>
          <h1
            style={{
              fontFamily: FONT_DISPLAY,
              fontWeight: 400,
              fontSize: "clamp(40px, 7vw, 92px)",
              lineHeight: 1.02,
              maxWidth: 820,
              letterSpacing: "-0.01em",
            }}
          >
            Jewelry cast from{" "}
            <span style={{ fontStyle: "italic", fontWeight: 400 }}>what the earth</span> remembers.
          </h1>
          <p style={{ marginTop: 26, fontSize: "clamp(15px, 4.4vw, 17px)", lineHeight: 1.65, maxWidth: 520, color: COLORS.textOnStrongMuted }}>
            Every piece begins as reclaimed gold and silver — old rings, coin scrap,
            a grandmother's chain — melted down and carved into something new.
            Nothing mined for this collection. Nothing rushed.
          </p>
          <div className="hero-actions flex flex-wrap items-center" style={{ gap: 18, marginTop: "clamp(28px, 6vw, 40px)" }}>
            <button
              className="mobile-touch-target"
              onClick={() => scrollTo("shop")}
              style={{
                background: COLORS.gold,
                color: COLORS.surfaceStrong,
                border: "none",
                padding: "16px 30px",
                fontSize: 14,
                letterSpacing: "0.04em",
                display: "inline-flex",
                alignItems: "center",
                gap: 10,
                borderRadius: 999,
              }}
            >
              Shop the collection <ArrowRight size={16} />
            </button>
            <button
              className="mobile-touch-target underline-grow"
              onClick={() => scrollTo("craft")}
              style={{ background: "none", border: "none", color: COLORS.textOnStrong, fontSize: 14, letterSpacing: "0.04em" }}
            >
              Read our story
            </button>
          </div>
        </div>
      </div>

      <button
        className="hero-scroll-cue"
        onClick={() => scrollTo("marquee")}
        aria-label="Scroll down"
        style={{
          position: "absolute",
          bottom: 28,
          left: "50%",
          transform: "translateX(-50%)",
          background: "none",
          border: "none",
          color: COLORS.textOnStrong,
          opacity: 0.7,
        }}
      >
        <ChevronDown size={22} />
      </button>
    </section>
  );
}
