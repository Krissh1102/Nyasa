import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Plus, Check, AlertTriangle } from "lucide-react";
import JewelArt from "./JewelArt";
import Reveal from "./Reveal";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { money } from "../utils/helpers";
import { fetchProducts, fetchCategories } from "../data/products";

export default function Shop({ filter, setFilter, addToCart, cart = [] }) {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [addedId, setAddedId] = useState(null);
  const [warnId, setWarnId] = useState(null);
  const [shakeId, setShakeId] = useState(null);

  // Fetch categories once on mount
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

  // Fetch products whenever the selected filter changes
  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);

    const categoryId = filter === "All" ? undefined : filter;

    fetchProducts({ categoryId })
      .then((data) => {
        if (!cancelled) setProducts(data.content);
      })
      .catch((err) => {
        if (!cancelled) setError(err.message);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [filter]);

  const qtyInCart = (id) => cart.find((c) => c.id === id)?.qty || 0;

  const handleAddToCart = (e, p) => {
    e.preventDefault();
    e.stopPropagation();

    const stockQuantity = typeof p.stockQuantity === "number" ? p.stockQuantity : Infinity;
    const remaining = stockQuantity - qtyInCart(p.id);

    if (remaining <= 0) {
      setWarnId(p.id);
      setShakeId(p.id);
      window.setTimeout(() => {
        setWarnId((current) => (current === p.id ? null : current));
      }, 1600);
      window.setTimeout(() => {
        setShakeId((current) => (current === p.id ? null : current));
      }, 500);
      return;
    }

    addToCart(p);
    setAddedId(p.id);
    window.setTimeout(() => {
      setAddedId((current) => (current === p.id ? null : current));
    }, 1500);
  };

  return (
   <section
  id="shop"
  style={{ background: COLORS.surfaceSoft }}
  className="px-4 sm:px-6 md:px-10 py-16 md:py-[100px]"
>
      <style>{`
        @keyframes shop-toast-in {
          from { opacity: 0; transform: translateY(4px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes shop-add-shake {
          0%, 100% { transform: translateX(0); }
          20% { transform: translateX(-4px); }
          40% { transform: translateX(3px); }
          60% { transform: translateX(-3px); }
          80% { transform: translateX(2px); }
        }
        .shop-add-shake {
          animation: shop-add-shake 0.4s ease;
        }
      `}</style>
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
              <button
                onClick={() => setFilter("All")}
               style={{
  border: `1px solid ${filter === "All" ? COLORS.surfaceStrong : COLORS.border}`,
  background: filter === "All" ? COLORS.surfaceStrong : "transparent",
  color: filter === "All" ? COLORS.textOnStrong : COLORS.text,
  padding: "12px 18px",
  fontSize: 13,
  letterSpacing: "0.03em",
}}
              >
                All
              </button>
              {categories.map((c) => (
                <button
                  key={c.id}
                  onClick={() => setFilter(c.id)}
                  style={{
                    border: `1px solid ${filter === c.id ? COLORS.surfaceStrong : COLORS.border}`,
                    background: filter === c.id ? COLORS.surfaceStrong : "transparent",
                    color: filter === c.id ? COLORS.textOnStrong : COLORS.text,
                    padding: "9px 18px",
                    fontSize: 13,
                    letterSpacing: "0.03em",
                  }}
                >
                  {c.name}
                </button>
              ))}
            </div>
          </div>
        </Reveal>

        {loading && <p style={{ padding: "20px 0" }}>Loading products…</p>}
        {error && <p style={{ padding: "20px 0", color: "crimson" }}>Couldn't load products: {error}</p>}

        {!loading && !error && (
          <div className="shop-grid grid grid-cols-2 md:grid-cols-4">
            {products.map((p, i) => {
              const stockQuantity = typeof p.stockQuantity === "number" ? p.stockQuantity : Infinity;
              const remaining = stockQuantity - qtyInCart(p.id);
              const fullyOut = stockQuantity <= 0;

              return (
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
                      {p.imageUrl && p.imageUrl.length > 0 ? (
                        <img
                          src={p.imageUrl[0]}
                          alt={p.name}
                          style={{ width: "100%", height: "100%", objectFit: "cover", opacity: fullyOut ? 0.55 : 1 }}
                        />
                      ) : (
                        <JewelArt type={p.art} style={{ width: "42%", color: COLORS.verdigris, opacity: fullyOut ? 0.55 : 1 }} />
                      )}
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
                        {p.categoryName}
                      </span>
                      {fullyOut && (
                        <span
                          style={{
                            position: "absolute",
                            top: 10,
                            right: 10,
                            fontSize: 10,
                            letterSpacing: "0.08em",
                            textTransform: "uppercase",
                            color: "#fff",
                            background: "#c0392b",
                            padding: "3px 8px",
                            borderRadius: 4,
                          }}
                        >
                          Sold out
                        </span>
                      )}
                    </div>
                    <div style={{ padding: "14px 14px 16px", display: "flex", flexDirection: "column", flex: 1 }}>
                      <h4 style={{ fontFamily: FONT_DISPLAY, fontSize: "clamp(15px, 4vw, 18px)", marginBottom: 4 }}>
                        {p.name}
                      </h4>
                      <p style={{ fontSize: 12.5, color: COLORS.textSoft, marginBottom: 14 }}>{p.material}</p>
                      <div className="flex items-center justify-between" style={{ marginTop: "auto", position: "relative" }}>
                        <span style={{ fontSize: 15 }}>{money(p.price)}</span>

                        {/* "Added to cart" / stock-limit warning toast */}
                        <span
                          style={{
                            position: "absolute",
                            right: 0,
                            bottom: "100%",
                            marginBottom: 8,
                            background: warnId === p.id ? "#c0392b" : COLORS.surfaceStrong,
                            color: "#fff",
                            fontSize: 11.5,
                            fontWeight: warnId === p.id ? 600 : 400,
                            letterSpacing: "0.03em",
                            padding: "6px 10px",
                            borderRadius: 20,
                            display: "flex",
                            alignItems: "center",
                            gap: 5,
                            whiteSpace: "nowrap",
                            pointerEvents: "none",
                            opacity: addedId === p.id || warnId === p.id ? 1 : 0,
                            transform: addedId === p.id || warnId === p.id ? "translateY(0)" : "translateY(4px)",
                            transition: "opacity 0.2s ease, transform 0.2s ease, background 0.2s ease",
                          }}
                        >
                          {warnId === p.id ? (
                            <>
                              <AlertTriangle size={12} />
                              {fullyOut ? "Out of stock" : "Stock limit reached"}
                            </>
                          ) : (
                            <>
                              <Check size={12} />
                              Added to cart
                            </>
                          )}
                        </span>

                        <button
                          onClick={(e) => handleAddToCart(e, p)}
                          aria-label={`Add ${p.name} to cart`}
                          className={`mobile-touch-target ${shakeId === p.id ? "shop-add-shake" : ""}`}
                          style={{
                            width: 45,
                            height: 45,
                            minWidth: 40,
                            borderRadius: "100%",
                            background: remaining <= 0 ? COLORS.surfaceMuted :  "#F3EFE8",
                            color: remaining <= 0 ? COLORS.textFaint : "#1D1B18",
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
              );
            })}
          </div>
        )}
      </div>
    </section>
  );
}