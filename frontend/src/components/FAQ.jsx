import React from "react";
import { ChevronDown } from "lucide-react";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { FAQS } from "../data/faqs";

export default function FAQ({ faqOpen, setFaqOpen }) {
  return (
    <section id="faq" style={{ background: COLORS.surfaceBase, padding: "110px 0" }} className="px-4 sm:px-6 md:px-10">
      <div style={{ maxWidth: 800, margin: "0 auto" }}>
        <Reveal>
          <p style={{ fontSize: 13, letterSpacing: "0.2em", textTransform: "uppercase", color: COLORS.rust, marginBottom: 14, textAlign: "center" }}>
            Questions
          </p>
          <h2 style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(28px, 4vw, 40px)", marginBottom: 50, textAlign: "center" }}>
            Good to know before you order
          </h2>
        </Reveal>
        {FAQS.map((item, i) => (
          <Reveal key={item.q} delay={i * 40}>
            <div style={{ borderBottom: `1px solid ${COLORS.border}` }}>
              <button
                onClick={() => setFaqOpen(faqOpen === i ? -1 : i)}
                style={{
                  width: "100%",
                  background: "none",
                  border: "none",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "22px 0",
                  textAlign: "left",
                }}
              >
                <span style={{ fontFamily: FONT_DISPLAY, fontSize: 18 }}>{item.q}</span>
                <ChevronDown
                  size={18}
                  style={{ transform: faqOpen === i ? "rotate(180deg)" : "rotate(0deg)", transition: "transform 0.3s ease", flexShrink: 0, marginLeft: 12 }}
                />
              </button>
              <div
                style={{
                  maxHeight: faqOpen === i ? 200 : 0,
                  overflow: "hidden",
                  transition: "max-height 0.35s ease",
                }}
              >
                <p style={{ fontSize: 15, lineHeight: 1.7, color: COLORS.textMuted, paddingBottom: 22, maxWidth: 620 }}>{item.a}</p>
              </div>
            </div>
          </Reveal>
        ))}
      </div>
    </section>
  );
}
