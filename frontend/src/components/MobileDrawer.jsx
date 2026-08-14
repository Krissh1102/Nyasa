import React from "react";
import { X } from "lucide-react";

const LINKS = ["Rings", "Necklaces", "Earrings"];

// Pulled straight from global.css custom properties so the drawer flips
// with data-theme="dark"/"light" automatically, no JS theme plumbing needed.
const TEXT = "var(--color-text)";
const MUTED = "var(--color-text-muted)";
const BORDER = "var(--color-border)";
const BG = "var(--color-surface-card)";

export default function MobileDrawer({ menuOpen, setMenuOpen, scrollTo, width = 280 }) {
  const handleNav = (id) => {
    scrollTo(id);
    setMenuOpen(false);
  };

  const linkStyle = {
    display: "block",
    width: "100%",
    textAlign: "left",
    padding: "20px 0",
    background: "none",
    border: "none",
    borderBottom: `1px solid ${BORDER}`,
    fontSize: 17,
    fontWeight: 500,
    color: TEXT,
  };

  return (
    <div
      role="navigation"
      aria-label="Mobile menu"
      className="nyasa-mobile-only"
      aria-hidden={!menuOpen}
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        width,
        height: "100vh",
        background: BG,
        color: TEXT,
        zIndex: 1,
        overflowY: "auto",
        boxSizing: "border-box",
        borderRight: `1px solid ${BORDER}`,
        transform: menuOpen ? "translateX(0)" : "translateX(-100%)",
        transition: "transform 0.3s ease, background-color 0.35s ease, color 0.35s ease, border-color 0.35s ease",
        pointerEvents: menuOpen ? "auto" : "none",
      }}
    >
      <div className="flex items-center justify-between px-6" style={{ height: 64, borderBottom: `1px solid ${BORDER}` }}>
        <span style={{ fontSize: 13, letterSpacing: "0.08em", color: MUTED, textTransform: "uppercase", fontWeight: 600 }}>
          Menu
        </span>
        <button
          onClick={() => setMenuOpen(false)}
          aria-label="Close menu"
          tabIndex={menuOpen ? 0 : -1}
          style={{ background: "none", border: "none", color: TEXT, padding: 8 }}
        >
          <X size={20} strokeWidth={1.8} />
        </button>
      </div>

      <div className="flex flex-col px-6" style={{ paddingTop: 8 }}>
        {LINKS.map((c) => (
          <button key={c} onClick={() => handleNav("shop")} tabIndex={menuOpen ? 0 : -1} style={linkStyle}>
            {c}
          </button>
        ))}
        <button onClick={() => handleNav("craft")} tabIndex={menuOpen ? 0 : -1} style={linkStyle}>
          The Craft
        </button>
        <button onClick={() => handleNav("faq")} tabIndex={menuOpen ? 0 : -1} style={{ ...linkStyle, borderBottom: "none" }}>
          FAQ
        </button>
      </div>
    </div>
  );
}