import React from "react";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { TESTIMONIALS } from "../data/testimonials";

export default function Testimonials({ testimonialIdx, setTestimonialIdx }) {
  return (
   <section
   id="testimonials"
  style={{ background: COLORS.surfaceAccent, color: COLORS.textOnStrong }}
  className="px-4 sm:px-6 md:px-10 py-16 md:py-[110px]"
>
      <div style={{ maxWidth: 800, margin: "0 auto", textAlign: "center" }}>
        <Reveal>
          <p style={{ fontSize: 13, letterSpacing: "0.2em", textTransform: "uppercase", color: COLORS.gold, marginBottom: 30 }}>
            Worn, not just bought
          </p>
          <div style={{ fontFamily: FONT_DISPLAY, fontStyle: "italic", fontSize: "clamp(90px, 12vw, 130px)", lineHeight: 0.3, color: COLORS.gold, opacity: 0.6 }}>
            "
          </div>
          <p style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(20px, 3vw, 28px)", lineHeight: 1.4, minHeight: 120, marginTop: 20 }}>
            {TESTIMONIALS[testimonialIdx].quote}
          </p>
          <p style={{ fontSize: 14, marginTop: 26, letterSpacing: "0.03em" }}>
            {TESTIMONIALS[testimonialIdx].name} — {TESTIMONIALS[testimonialIdx].role}
          </p>
          <div className="flex items-center justify-center" style={{ gap: 10, marginTop: 34 }}>
            {TESTIMONIALS.map((t, i) => (
              <button
                key={t.name}
                onClick={() => setTestimonialIdx(i)}
                aria-label={`Show testimonial ${i + 1}`}
                style={{
  width: 8,
  height: 8,
  borderRadius: "50%",
  border: "none",
  background: i === testimonialIdx ? COLORS.gold : COLORS.dotInactive,
  padding: 0,
}}
              />
            ))}
          </div>
        </Reveal>
      </div>
    </section>
  );
}
