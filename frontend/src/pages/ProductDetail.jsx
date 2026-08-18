import React, { useState, useEffect, useRef } from "react";
import { useParams, Link } from "react-router-dom";
import { ArrowLeft, Plus, Minus } from "lucide-react";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { fetchProductById } from "../data/products";
import { money } from "../utils/helpers";

export default function ProductDetail({ addToCart, cart = [], updateQty }) {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [qty, setQty] = useState(1); // used only BEFORE the item is in the cart
  const [added, setAdded] = useState(false);
  const [activeImage, setActiveImage] = useState(0);
  const [imageLoaded, setImageLoaded] = useState(false);
  const [mounted, setMounted] = useState(false);

  const [stockWarning, setStockWarning] = useState(false);
  const [shakeKey, setShakeKey] = useState(0);
  const warningTimer = useRef(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setProduct(null);
    setActiveImage(0);
    setMounted(false);
    setQty(1);

    fetchProductById(id)
      .then((data) => {
        if (!cancelled) setProduct(data);
      })
      .catch(() => {
        if (!cancelled) setProduct(null);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [id]);

  useEffect(() => {
    if (!loading && product) {
      const t = requestAnimationFrame(() => setMounted(true));
      return () => cancelAnimationFrame(t);
    }
  }, [loading, product]);

  useEffect(() => {
    setImageLoaded(false);
  }, [activeImage]);

  useEffect(() => () => clearTimeout(warningTimer.current), []);

  if (loading) {
    return (
      <section style={{ padding: "100px 22px", textAlign: "center" }}>
        <p style={{ fontSize: 14, color: COLORS.textMuted }}>Loading…</p>
      </section>
    );
  }

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

  const images = product.imageUrl && product.imageUrl.length > 0 ? product.imageUrl : [];
  const stockQuantity = typeof product.stockQuantity === "number" ? product.stockQuantity : Infinity;
  const outOfStock = stockQuantity <= 0;

  // Cart-aware quantity: once the product is in the cart, the stepper
  // reads/writes the cart directly so both screens stay in sync.
  const cartItem = cart.find((i) => i.id === product.id);
  const cartQty = cartItem?.qty || 0;
  const inCart = cartQty > 0;
  const displayQty = inCart ? cartQty : qty;
  const atMax = displayQty >= stockQuantity;

  const triggerStockWarning = () => {
    setStockWarning(true);
    setShakeKey((k) => k + 1);
    clearTimeout(warningTimer.current);
    warningTimer.current = setTimeout(() => setStockWarning(false), 2200);
  };

  const handleIncrement = () => {
    if (atMax) {
      triggerStockWarning();
      return;
    }
    if (inCart) {
      updateQty(product.id, 1, stockQuantity);
    } else {
      setQty((q) => q + 1);
    }
  };

  const handleDecrement = () => {
    if (inCart) {
      updateQty(product.id, -1, stockQuantity);
    } else {
      setQty((q) => Math.max(1, q - 1));
    }
  };

  const handleAdd = () => {
    if (outOfStock || inCart) return;
    addToCart(product);
    setQty(1);
    setAdded(true);
    setTimeout(() => setAdded(false), 1600);
  };

  return (
    <section style={{ padding: "40px 22px 100px", maxWidth: 1080, margin: "0 auto" }}>
      <style>{`
        @keyframes pd-fade-up {
          from { opacity: 0; transform: translateY(14px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes pd-pop {
          0% { transform: scale(1); }
          35% { transform: scale(1.05); }
          100% { transform: scale(1); }
        }
        @keyframes pd-check-in {
          from { opacity: 0; transform: scale(0.6) rotate(-10deg); }
          to { opacity: 1; transform: scale(1) rotate(0deg); }
        }
        @keyframes pd-shake {
          0%, 100% { transform: translateX(0); }
          20% { transform: translateX(-6px); }
          40% { transform: translateX(5px); }
          60% { transform: translateX(-4px); }
          80% { transform: translateX(3px); }
        }
        .pd-back-link {
          transition: gap 0.25s ease, color 0.25s ease;
        }
        .pd-back-link:hover {
          gap: 10px;
          color: ${COLORS.text};
        }
        .pd-thumb {
          transition: transform 0.25s ease, border-color 0.25s ease, opacity 0.25s ease;
        }
        .pd-thumb:hover {
          transform: translateY(-3px);
        }
        .pd-qty-btn {
          transition: background 0.2s ease, transform 0.15s ease;
        }
        .pd-qty-btn:hover {
          background: ${COLORS.surfaceSoft};
        }
        .pd-qty-btn:active {
          transform: scale(0.9);
        }
        .pd-qty-btn:disabled {
          opacity: 0.35;
          cursor: not-allowed;
        }
        .pd-add-btn {
          transition: background 0.3s ease, transform 0.15s ease, box-shadow 0.3s ease;
        }
        .pd-add-btn:hover:not(:disabled) {
          transform: translateY(-2px);
          box-shadow: 0 10px 24px rgba(0, 0, 0, 0.16);
        }
        .pd-add-btn:active:not(:disabled) {
          transform: translateY(0) scale(0.98);
        }
        .pd-add-btn.pd-added {
          animation: pd-pop 0.4s ease;
        }
        .pd-add-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        .pd-main-image {
          transition: opacity 0.4s ease, transform 0.6s ease;
        }
        .pd-check {
          animation: pd-check-in 0.35s ease;
        }
        .pd-qty-shake {
          animation: pd-shake 0.4s ease;
        }
        .pd-stock-warning {
          animation: pd-fade-up 0.3s ease;
        }
      `}</style>

      <Link
        to="/"
        className="pd-back-link"
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: 6,
          fontSize: 13,
          color: COLORS.textMuted,
          marginBottom: 32,
          textDecoration: "none",
          opacity: mounted ? 1 : 0,
          transform: mounted ? "translateY(0)" : "translateY(-6px)",
          transition: "opacity 0.5s ease, transform 0.5s ease",
        }}
      >
        <ArrowLeft size={15} />
        Back to shop
      </Link>

      <div className="flex flex-col md:flex-row" style={{ gap: 48, alignItems: "flex-start" }}>
        <div
          style={{
            flex: 1,
            width: "100%",
            opacity: mounted ? 1 : 0,
            transform: mounted ? "translateY(0)" : "translateY(14px)",
            transition: "opacity 0.6s ease, transform 0.6s ease",
          }}
        >
          <div
            style={{
              width: "100%",
              aspectRatio: "1 / 1",
              background: COLORS.surfaceSoft,
              border: `1px solid ${COLORS.border}`,
              borderRadius: 20,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              position: "relative",
              overflow: "hidden",
              marginBottom: images.length > 1 ? 12 : 0,
            }}
          >
            {images.length > 0 ? (
              <img
                key={activeImage}
                src={images[activeImage]}
                alt={product.name}
                onLoad={() => setImageLoaded(true)}
                className="pd-main-image"
                style={{
                  width: "100%",
                  height: "100%",
                  objectFit: "cover",
                  opacity: imageLoaded ? 1 : 0,
                  transform: imageLoaded ? "scale(1)" : "scale(1.03)",
                }}
              />
            ) : (
              <span style={{ fontSize: 13, color: COLORS.textFaint }}>No image available</span>
            )}
            <span
              style={{
                position: "absolute",
                top: 16,
                left: 16,
                fontSize: 11,
                letterSpacing: "0.1em",
                textTransform: "uppercase",
                color: COLORS.rust,
                background: COLORS.surfaceSoft,
                padding: "3px 8px",
                borderRadius: 4,
              }}
            >
              {product.categoryName}
            </span>
            {outOfStock && (
              <span
                style={{
                  position: "absolute",
                  top: 16,
                  right: 16,
                  fontSize: 11,
                  letterSpacing: "0.08em",
                  textTransform: "uppercase",
                  color: COLORS.textOnStrong,
                  background: COLORS.rust,
                  padding: "3px 10px",
                  borderRadius: 4,
                }}
              >
                Sold out
              </span>
            )}
          </div>

          {images.length > 1 && (
            <div className="flex" style={{ gap: 10 }}>
              {images.map((src, i) => (
                <button
                  key={src + i}
                  onClick={() => setActiveImage(i)}
                  className="pd-thumb"
                  style={{
                    width: 64,
                    height: 64,
                    borderRadius: 10,
                    overflow: "hidden",
                    border: `1px solid ${i === activeImage ? COLORS.surfaceStrong : COLORS.border}`,
                    padding: 0,
                    cursor: "pointer",
                    flexShrink: 0,
                    opacity: i === activeImage ? 1 : 0.65,
                  }}
                  aria-label={`View image ${i + 1}`}
                >
                  <img
                    src={src}
                    alt={`${product.name} ${i + 1}`}
                    style={{ width: "100%", height: "100%", objectFit: "cover" }}
                  />
                </button>
              ))}
            </div>
          )}
        </div>

        <div
          style={{
            flex: 1,
            width: "100%",
            opacity: mounted ? 1 : 0,
            transform: mounted ? "translateY(0)" : "translateY(14px)",
            transition: "opacity 0.6s ease 0.1s, transform 0.6s ease 0.1s",
          }}
        >
          <h1 style={{ fontFamily: FONT_DISPLAY, fontSize: 32, marginBottom: 10, color: COLORS.text }}>
            {product.name}
          </h1>
          <p style={{ fontFamily: FONT_DISPLAY, fontSize: 26, marginBottom: 18, color: COLORS.text }}>
            {money(product.price)}
          </p>

          {product.description && (
            <p style={{ fontSize: 14, lineHeight: 1.6, color: COLORS.textSoft, marginBottom: 28 }}>
              {product.description}
            </p>
          )}
          {product.weightGrams > 0 && (
            <p style={{ fontSize: 12.5, color: COLORS.textFaint, marginBottom: 28, marginTop: -18 }}>
              Weight: {product.weightGrams >= 1000
                ? `${(product.weightGrams / 1000).toFixed(2)} kg`
                : `${product.weightGrams} g`}
            </p>
          )}

          {!outOfStock && stockQuantity <= 5 && (
            <p style={{ fontSize: 12.5, color: COLORS.rust, marginBottom: 16, marginTop: -18 }}>
              Only {stockQuantity} left in stock
            </p>
          )}

          {inCart && (
            <div
              key={shakeKey}
              className={`flex items-center ${stockWarning ? "pd-qty-shake" : ""}`}
              style={{
                border: `1px solid ${COLORS.border}`,
                borderRadius: 12,
                width: "fit-content",
                marginBottom: 10,
                overflow: "hidden",
                opacity: outOfStock ? 0.5 : 1,
              }}
            >
              <button
                onClick={handleDecrement}
                className="pd-qty-btn"
                style={{ background: "none", border: "none", padding: "10px 14px", color: COLORS.text }}
                aria-label="Decrease quantity"
                disabled={outOfStock}
              >
                <Minus size={14} />
              </button>
              <span style={{ fontSize: 14, minWidth: 24, textAlign: "center" }}>{displayQty}</span>
              <button
                onClick={handleIncrement}
                className="pd-qty-btn"
                style={{ background: "none", border: "none", padding: "10px 14px", color: COLORS.text }}
                aria-label="Increase quantity"
                disabled={outOfStock}
              >
                <Plus size={14} />
              </button>
            </div>
          )}

          {stockWarning && (
            <p className="pd-stock-warning" style={{ fontSize: 12.5, color: COLORS.rust, marginBottom: 14 }}>
              {outOfStock ? "This piece is out of stock" : `Only ${stockQuantity} available`}
            </p>
          )}

          {!inCart && (
            <button
              onClick={handleAdd}
              className={`pd-add-btn ${added ? "pd-added" : ""}`}
              disabled={outOfStock}
              style={{
                width: "100%",
                maxWidth: 320,
                background: added ? COLORS.verdigrisSoft : "#F3EFE8",
                color: added ? COLORS.verdigris : "#1D1B18",
                border: added ? `1px solid ${COLORS.verdigris}` : "1px solid transparent",
                borderRadius: 14,
                padding: "15px 0",
                fontSize: 14,
                letterSpacing: "0.03em",
                cursor: outOfStock ? "not-allowed" : "pointer",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: 8,
              }}
            >
              {added && <span className="pd-check">✓</span>}
              {outOfStock ? "Out of stock" : added ? "Added to bag" : "Add to bag"}
            </button>
          )}

          {inCart && (
            <p style={{ fontSize: 12.5, color: COLORS.textMuted, marginBottom: 4 }}>
              In your bag — use the buttons above to adjust quantity.
            </p>
          )}

          <p style={{ fontSize: 11.5, color: COLORS.textFaint, marginTop: 14 }}>
            Shipping and duties calculated at checkout.
          </p>
        </div>
      </div>
    </section>
  );
}