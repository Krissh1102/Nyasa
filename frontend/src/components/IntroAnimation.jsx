import React, { useEffect, useRef, useState } from "react";
import { COLORS, FONT_DISPLAY } from "../constants/theme";

const INTRO_SEEN_KEY = "nyasa-intro-seen";

export default function IntroAnimation({ onDone }) {
  const [phase, setPhase] = useState("in"); // "in" -> "hold" -> "out" -> unmount
  const [skip] = useState(
    () => typeof window !== "undefined" && sessionStorage.getItem(INTRO_SEEN_KEY) === "1"
  );

  // Always call the LATEST onDone without making the timer effect below
  // re-run every time the parent re-renders and passes a new function
  const onDoneRef = useRef(onDone);
  useEffect(() => {
    onDoneRef.current = onDone;
  }, [onDone]);

  useEffect(() => {
    if (skip) {
      onDoneRef.current();
      return;
    }

    document.body.style.overflow = "hidden";

    const t1 = setTimeout(() => setPhase("hold"), 900);
    const t2 = setTimeout(() => setPhase("out"), 1500);
    const t3 = setTimeout(() => {
      document.body.style.overflow = "";
      sessionStorage.setItem(INTRO_SEEN_KEY, "1");
      onDoneRef.current();
    }, 2150);

    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
      document.body.style.overflow = "";
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [skip]); // runs once on mount only — never re-fires on scroll/re-render

  if (skip) return null;

  return (
    <div
      aria-hidden="true"
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 9999,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: COLORS.surfaceStrong,
        transform: phase === "out" ? "translateY(-100%)" : "translateY(0)",
        transition: "transform 0.65s cubic-bezier(0.76, 0, 0.24, 1)",
        pointerEvents: phase === "out" ? "none" : "auto",
      }}
    >
      <style>{`
        @keyframes nyasaLetterIn {
          0% { opacity: 0; transform: translateY(14px); letter-spacing: 0.5em; }
          100% { opacity: 1; transform: translateY(0); letter-spacing: 0.22em; }
        }
        @keyframes nyasaLineGrow {
          0% { width: 0%; }
          100% { width: 100%; }
        }
        .nyasa-intro-word {
          animation: nyasaLetterIn 0.9s cubic-bezier(0.22, 1, 0.36, 1) forwards;
        }
        .nyasa-intro-line {
          animation: nyasaLineGrow 0.7s 0.5s cubic-bezier(0.65, 0, 0.35, 1) forwards;
        }
        @media (prefers-reduced-motion: reduce) {
          .nyasa-intro-word, .nyasa-intro-line { animation: none; opacity: 1; width: 100%; }
        }
      `}</style>

      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 18 }}>
        <div
          className="nyasa-intro-word"
          style={{
            fontFamily: FONT_DISPLAY,
            fontSize: "clamp(28px, 6vw, 48px)",
            color: COLORS.textOnStrong,
            letterSpacing: "0.22em",
            opacity: 0,
          }}
        >
          NYASA
        </div>
        <div
          className="nyasa-intro-line"
          style={{
            height: 1,
            width: 0,
            background: COLORS.textOnStrongMuted,
          }}
        />
      </div>
    </div>
  );
}