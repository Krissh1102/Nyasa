import React from "react";
import { Link } from "react-router-dom";
import { COLORS, FONT_DISPLAY } from "../constants/theme";

export default function NotFound() {
  return (
    <section
      style={{
        minHeight: "50vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        textAlign: "center",
        padding: "100px 22px",
      }}
    >
      <p style={{ fontFamily: FONT_DISPLAY, fontSize: 28, marginBottom: 12, color: COLORS.text }}>
        Page not found
      </p>
      <p style={{ fontSize: 14, color: COLORS.textMuted, marginBottom: 28 }}>
        The page you're looking for doesn't exist or may have moved.
      </p>
      <Link
        to="/"
        style={{
          background: COLORS.surfaceStrong,
          color: COLORS.textOnStrong,
          padding: "13px 26px",
          borderRadius: 14,
          fontSize: 14,
          textDecoration: "none",
        }}
      >
        Back to shop
      </Link>
    </section>
  );
}