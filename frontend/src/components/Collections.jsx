import React, { useEffect, useRef } from "react";
import { ArrowUpRight } from "lucide-react";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { COLLECTIONS } from "../data/collections";

export default function Collections({ activeCollection, setActiveCollection, setFilter, scrollTo }) {
  const collectionRefs = useRef({});

  useEffect(() => {
    const observers = [];
    COLLECTIONS.forEach((c) => {
      const node = collectionRefs.current[c.key];
      if (!node) return;
      const io = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) setActiveCollection(c.key);
          });
        },
        { threshold: 0.5 }
      );
      io.observe(node);
      observers.push(io);
    });
    return () => observers.forEach((io) => io.disconnect());
  }, [setActiveCollection]);

  return (
  <section
  style={{ background: COLORS.surfaceBase }}
  className="px-4 sm:px-6 md:px-10 py-16 md:py-[100px]"
>
      <div style={{ maxWidth: 1240, margin: "0 auto" }}>
        <Reveal>
          <p style={{ fontSize: 13, letterSpacing: "0.2em", textTransform: "uppercase", color: COLORS.rust, marginBottom: 14 }}>
            Three collections
          </p>
          <h2 style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(30px, 4vw, 46px)", maxWidth: 640, marginBottom: 60 }}>
            Made for the parts of you that are always visible.
          </h2>
        </Reveal>

        <div className="flex flex-col md:flex-row" style={{ gap: 36 }}>
          <div className="hidden md:block" style={{ width: "38%", position: "sticky", top: 120, alignSelf: "flex-start", height: 420 }}>
            <div
              style={{
                height: "100%",
                border: `1px solid ${COLORS.border}`,
                background: COLORS.surfaceSoft,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                position: "relative",
              }}
            >
             {COLLECTIONS.map((c) => (
  <img
    key={c.key}
    src={c.image}
    alt={c.title}
    style={{
      position: "absolute",
      width: "75%",
      height: "75%",
      objectFit: "contain",
      opacity: activeCollection === c.key ? 1 : 0,
      transform: activeCollection === c.key ? "scale(1)" : "scale(0.92)",
      transition: "opacity 0.5s ease, transform 0.5s ease",
      pointerEvents: "none",
    }}
  />
))}
            </div>
          </div>

          <div style={{ width: "100%", maxWidth: 560 }}>
            {COLLECTIONS.map((c, idx) => (
              <div
                key={c.key}
                ref={(el) => (collectionRefs.current[c.key] = el)}
               style={{
  paddingBottom: idx === COLLECTIONS.length - 1 ? 0 : 64,
  borderBottom: idx === COLLECTIONS.length - 1 ? "none" : `1px solid ${COLORS.border}`,
  marginBottom: idx === COLLECTIONS.length - 1 ? 0 : 64,
}}
              >
                <Reveal>
                 <div
  className="md:hidden"
  style={{
    width: 100,
    height: 100,
    marginBottom: 20,
  }}
>
  <img
    src={c.image}
    alt={c.title}
    style={{
      width: "100%",
      height: "100%",
      objectFit: "contain",
      display: "block",
    }}
  />
</div>
                  <p style={{ fontSize: 13, letterSpacing: "0.15em", textTransform: "uppercase", color: COLORS.gold, marginBottom: 10 }}>
                    {c.kicker}
                  </p>
                <h3
  style={{
    fontFamily: FONT_DISPLAY,
    fontSize: "clamp(24px, 6vw, 32px)",
    marginBottom: 16,
  }}
>
  {c.title}
</h3>
                  <p style={{ fontSize: 15.5, lineHeight: 1.7, color: COLORS.textMuted, marginBottom: 22 }}>{c.copy}</p>
                  <button
                    onClick={() => {
                      setFilter(c.key);
                      scrollTo("shop");
                    }}
                    className="underline-grow"
                    style={{ background: "none", border: "none", fontSize: 14, display: "inline-flex", alignItems: "center", gap: 8, color: COLORS.text }}
                  >
                    Shop {c.title} <ArrowUpRight size={15} />
                  </button>
                </Reveal>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
