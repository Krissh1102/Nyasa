import React from "react";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { PROCESS } from "../data/process";

export default function Process() {
  return (
    <section style={{ background: COLORS.surfaceBase, padding: "110px 0" }} className="px-4 sm:px-6 md:px-10">
      <div style={{ maxWidth: 1240, margin: "0 auto" }}>
        <Reveal>
          <p style={{ fontSize: 13, letterSpacing: "0.2em", textTransform: "uppercase", color: COLORS.rust, marginBottom: 14 }}>
            From sketch to box
          </p>
          <h2 style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(28px, 4vw, 44px)", marginBottom: 60, maxWidth: 620 }}>
            Five steps, and every one of them by hand.
          </h2>
        </Reveal>
        <div className="process-grid grid grid-cols-1 md:grid-cols-5" style={{ gap: 0 }}>
          {PROCESS.map((step, i) => (
            <Reveal key={step.n} delay={i * 90}>
              <div
                className="process-step"
                style={{
                  padding: "0 22px 0 0",
                  borderTop: `1px solid ${COLORS.border}`,
                  paddingTop: 24,
                }}
              >
                <div style={{ fontFamily: FONT_DISPLAY, fontStyle: "italic", fontSize: 15, color: COLORS.gold, marginBottom: 14 }}>
                  {step.n}
                </div>
                <h4 style={{ fontFamily: FONT_DISPLAY, fontSize: 20, marginBottom: 10 }}>{step.title}</h4>
                <p style={{ fontSize: 14, lineHeight: 1.65, color: COLORS.textMuted }}>{step.copy}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
