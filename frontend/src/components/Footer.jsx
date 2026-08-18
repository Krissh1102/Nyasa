import React, { useEffect, useState } from "react";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { fetchCategories } from "../data/products";

export default function Footer({ setFilter, scrollTo }) {
   const [categories, setCategories] = useState([]);

  useEffect(() => {
    let cancelled = false;
    fetchCategories()
      .then((data) => {
        if (!cancelled) setCategories(data);
      })
      .catch(() => {
        if (!cancelled) setCategories([]);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const goToCategory = (label) => {
    const match = categories.find(
      (c) => c.name.toLowerCase() === label.toLowerCase()
    );
    setFilter(match ? match.id : "All");
    scrollTo("shop");
  };



  return (
    <footer style={{ background: COLORS.surfaceStrong, color: COLORS.textOnStrongMuted, borderTop: `1px solid ${COLORS.borderOnStrong}` }} className="px-4 sm:px-6 md:px-10">
      <div style={{ maxWidth: 1240, margin: "0 auto", padding: "60px 0 30px" }}>
        <div className="grid grid-cols-2 md:grid-cols-4" style={{ gap: 32, marginBottom: 50 }}>
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 8, color: COLORS.textOnStrong, fontFamily: FONT_DISPLAY, fontSize: 20, marginBottom: 14 }}>
              <img src="/logo/logo-dark.png" alt="Nyasa" style={{  width: 30, height: 22, objectFit: "cover",  transform: "scale(1.6)", // zooms in — tweak this number to taste
      objectPosition: "center",  }} />
              NYASA
            </div>
            <p style={{ fontSize: 13.5, lineHeight: 1.6, maxWidth: 220 }}>Fine jewelry, hand-cast from reclaimed metal since 2019.</p>
          </div>
          <div>
            <h5 style={{ color: COLORS.textOnStrong, fontSize: 13, letterSpacing: "0.1em", textTransform: "uppercase", marginBottom: 16 }}>Shop</h5>
              {["Rings", "Necklaces", "Earrings"].map((c) => (
      <button
        key={c}
        onClick={() => goToCategory(c)}
        style={{ display: "block", background: "none", border: "none", color: "inherit", fontSize: 13.5, padding: "5px 0" }}
      >
        {c}
      </button>
    ))}
          </div>
          <div>
            <h5 style={{ color: COLORS.textOnStrong, fontSize: 13, letterSpacing: "0.1em", textTransform: "uppercase", marginBottom: 16 }}>Studio</h5>
            {[
              ["The Craft", "craft"],
              ["FAQ", "faq"],
            ].map(([label, id]) => (
              <button key={id} onClick={() => scrollTo(id)} style={{ display: "block", background: "none", border: "none", color: "inherit", fontSize: 13.5, padding: "5px 0" }}>
                {label}
              </button>
            ))}
          </div>
          <div>
            <h5 style={{ color: COLORS.textOnStrong, fontSize: 13, letterSpacing: "0.1em", textTransform: "uppercase", marginBottom: 16 }}>Contact</h5>
            <p style={{ fontSize: 13.5, padding: "5px 0" }}>hello@nyasa.com</p>
            <p style={{ fontSize: 13.5, padding: "5px 0" }}>+1 (415) 555-0148</p>
          </div>
        </div>
        <div
          className="flex flex-col sm:flex-row"
          style={{ borderTop: `1px solid ${COLORS.borderOnStrong}`, paddingTop: 22, fontSize: 12.5, gap: 6, justifyContent: "space-between" }}
        >
          <span>© {new Date().getFullYear()} Nyasa. All rights reserved.</span>
          <span>Made-to-order, cast to last.</span>
        </div>
      </div>
    </footer>
  );
}
