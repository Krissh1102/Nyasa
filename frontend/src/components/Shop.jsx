import React from "react";
import { Link } from "react-router-dom";
import { Plus } from "lucide-react";
import JewelArt from "./JewelArt";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { PRODUCTS } from "../data/products";
import { money } from "../utils/helpers";

export default function Shop({ filter, setFilter, addToCart }) {
  const filteredProducts = filter === "All" ? PRODUCTS : PRODUCTS.filter((p) => p.category === filter);

  return (
    <section id="shop" style={{ background: COLORS.surfaceSoft, padding: "100px 0" }} className="px-4 sm:px-6 md:px-10">
      <div style={{ maxWidth: 1240, margin: "0 auto" }}>
        <Reveal>
          <div className="flex flex-col md:flex-row md:items-end md:justify-between" style={{ gap: 20, marginBottom: 50 }}>
            <div>
              <p style={{ fontSize: 13, letterSpacing: "0.2em", textTransform: "uppercase", color: COLORS.rust, marginBottom: 14 }}>
                The shop
              </p>
              <h2 style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(28px, 4vw, 44px)" }}>Current pieces</h2>
            </div>
            <div className="mobile-pill-row" style={{ gap: 10 }}>
              {["All", "Rings", "Necklaces", "Earrings"].map((f) => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  style={{
                    border: `1px solid ${filter === f ? COLORS.surfaceStrong : COLORS.border}`,
                    background: filter === f ? COLORS.surfaceStrong : "transparent",
                    color: filter === f ? COLORS.textOnStrong : COLORS.text,
                    padding: "9px 18px",
                    fontSize: 13,
                    letterSpacing: "0.03em",
                  }}
                >
                  {f}
                </button>
              ))}
            </div>
          </div>
        </Reveal>

        <div className="shop-grid grid grid-cols-2 md:grid-cols-4">
          {filteredProducts.map((p, i) => (
            <Reveal key={p.id} delay={(i % 4) * 60}>
              <Link
                to={`/product/${p.id}`}
                style={{
                  background: COLORS.surfaceCard,
                  border: `1px solid ${COLORS.border}`,
                  display: "flex",
                  flexDirection: "column",
                  height: "100%",
                  textDecoration: "none",
                  color: "inherit",
                }}
              >
                <div
                  style={{
                    aspectRatio: "1 / 1",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    borderBottom: `1px solid ${COLORS.border}`,
                    position: "relative",
                    overflow: "hidden",
                  }}
                >
                  <JewelArt type={p.art} style={{ width: "42%", color: COLORS.verdigris }} />
                  <span
                    style={{
                      position: "absolute",
                      top: 10,
                      left: 10,
                      fontSize: 10.5,
                      letterSpacing: "0.1em",
                      textTransform: "uppercase",
                      color: COLORS.rust,
                    }}
                  >
                    {p.category}
                  </span>
                </div>
                <div style={{ padding: "14px 14px 16px", display: "flex", flexDirection: "column", flex: 1 }}>
                  <h4 style={{ fontFamily: FONT_DISPLAY, fontSize: 18, marginBottom: 4 }}>{p.name}</h4>
                  <p style={{ fontSize: 12.5, color: COLORS.textSoft, marginBottom: 14 }}>{p.material}</p>
                  <div className="flex items-center justify-between" style={{ marginTop: "auto" }}>
                    <span style={{ fontSize: 15 }}>{money(p.price)}</span>
                    <button
                      onClick={(e) => {
                        e.preventDefault();
                        e.stopPropagation();
                        addToCart(p);
                      }}
                      aria-label={`Add ${p.name} to cart`}
                      style={{
                        width: 32,
                        height: 32,
                        borderRadius: "50%",
                        background: COLORS.surfaceStrong,
                        color: COLORS.textOnStrong,
                        border: "none",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                      }}
                    >
                      <Plus size={15} />
                    </button>
                  </div>
                </div>
              </Link>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}