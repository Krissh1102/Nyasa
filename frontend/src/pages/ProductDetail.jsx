import React, { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { ArrowLeft, Plus, Minus } from "lucide-react";
import JewelArt from "../components/JewelArt";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { PRODUCTS } from "../data/products";
import { money } from "../utils/helpers";

export default function ProductDetail({ addToCart }) {
  const { id } = useParams();
  const product = PRODUCTS.find((p) => String(p.id) === String(id));
  const [qty, setQty] = useState(1);
  const [added, setAdded] = useState(false);

  if (!product) {
    return (
      <section style={{ padding: "100px 22px", textAlign: "center" }}>
        <p style={{ fontFamily: FONT_DISPLAY, fontSize: 22, marginBottom: 16, color: COLORS.text }}>
          We couldn't find that piece.
        </p>
        <Link to="/" style={{ color: COLORS.verdigris, fontSize: 14 }}>
          Back to shop
        </Link>
      </section>
    );
  }

  const handleAdd = () => {
    for (let i = 0; i < qty; i++) addToCart(product);
    setAdded(true);
    setTimeout(() => setAdded(false), 1600);
  };

  return (
    <section style={{ padding: "40px 22px 100px", maxWidth: 1080, margin: "0 auto" }}>
      <Link
        to="/"
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: 6,
          fontSize: 13,
          color: COLORS.textMuted,
          marginBottom: 32,
          textDecoration: "none",
        }}
      >
        <ArrowLeft size={15} />
        Back to shop
      </Link>

      <div
        className="flex flex-col md:flex-row"
        style={{ gap: 48, alignItems: "flex-start" }}
      >
        <div
          style={{
            flex: 1,
            width: "100%",
            aspectRatio: "1 / 1",
            background: COLORS.surfaceSoft,
            border: `1px solid ${COLORS.border}`,
            borderRadius: 20,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            position: "relative",
          }}
        >
          <JewelArt type={product.art} style={{ width: "40%", color: COLORS.verdigris }} />
          <span
            style={{
              position: "absolute",
              top: 16,
              left: 16,
              fontSize: 11,
              letterSpacing: "0.1em",
              textTransform: "uppercase",
              color: COLORS.rust,
            }}
          >
            {product.category}
          </span>
        </div>

        <div style={{ flex: 1, width: "100%" }}>
          <h1 style={{ fontFamily: FONT_DISPLAY, fontSize: 32, marginBottom: 10, color: COLORS.text }}>
            {product.name}
          </h1>
          <p style={{ fontSize: 14, color: COLORS.textSoft, marginBottom: 18 }}>{product.material}</p>
          <p style={{ fontFamily: FONT_DISPLAY, fontSize: 26, marginBottom: 28, color: COLORS.text }}>
            {money(product.price)}
          </p>

          <div
            className="flex items-center"
            style={{
              border: `1px solid ${COLORS.border}`,
              borderRadius: 12,
              width: "fit-content",
              marginBottom: 20,
              overflow: "hidden",
            }}
          >
            <button
              onClick={() => setQty((q) => Math.max(1, q - 1))}
              style={{ background: "none", border: "none", padding: "10px 14px", color: COLORS.text }}
              aria-label="Decrease quantity"
            >
              <Minus size={14} />
            </button>
            <span style={{ fontSize: 14, minWidth: 24, textAlign: "center" }}>{qty}</span>
            <button
              onClick={() => setQty((q) => q + 1)}
              style={{ background: "none", border: "none", padding: "10px 14px", color: COLORS.text }}
              aria-label="Increase quantity"
            >
              <Plus size={14} />
            </button>
          </div>

          <button
            onClick={handleAdd}
            style={{
              width: "100%",
              maxWidth: 320,
              background: added ? COLORS.verdigris : COLORS.surfaceStrong,
              color: COLORS.textOnStrong,
              border: "none",
              borderRadius: 14,
              padding: "15px 0",
              fontSize: 14,
              letterSpacing: "0.03em",
              cursor: "pointer",
              transition: "background 0.2s ease",
            }}
          >
            {added ? "Added to bag" : "Add to bag"}
          </button>

          <p style={{ fontSize: 11.5, color: COLORS.textFaint, marginTop: 14 }}>
            Shipping and duties calculated at checkout.
          </p>
        </div>
      </div>
    </section>
  );
}