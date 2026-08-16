import React from "react";
import { useLocation } from "react-router-dom";
import { ShoppingBag, Menu, X, Moon, Sun } from "lucide-react";
import JewelArt from "./JewelArt";
import { COLORS, FONT_DISPLAY, THEME_MODES } from "../constants/theme";

// Hardcoded so the drawer can NEVER render invisible, regardless of what
// COLORS resolves to. Deliberately different from a plain white page so you
// can visually confirm the drawer is actually there.
const DRAWER_BG = "#f4f4f6";
const DRAWER_TEXT = "#16161d";
const DRAWER_MUTED = "#6e7180";
const DRAWER_BORDER = "#dcdce1";

const LINKS = ["Order"];

export default function Nav({
  scrolled,
  menuOpen,
  setMenuOpen,
  cartOpen,
  setCartOpen,
  cartCount,
  bump,
  scrollTo,
  setFilter,
  themeMode,
  toggleTheme,
}) {
  const location = useLocation();
  const isProductPage = location.pathname.startsWith("/product/");

 const navTextColor = scrolled || menuOpen || isProductPage ? COLORS.text : COLORS.textOnStrong;
  const nextThemeLabel = themeMode === THEME_MODES.DARK ? "light" : "dark";

  const handleDrawerNav = (id) => {
    scrollTo(id);
    setMenuOpen(false);
  };

  const linkStyle = {
    display: "block",
    width: "100%",
    textAlign: "left",
    padding: "16px 0",
    background: "none",
    border: "none",
    borderBottom: `1px solid ${DRAWER_BORDER}`,
    fontSize: 17,
    fontWeight: 500,
    color: DRAWER_TEXT,
  };

  return (
    <>
      <header
        style={{
          position: "fixed",
          top: 0,
          left: 0,
          right: 0,
          zIndex: 50,
         background: scrolled || menuOpen || isProductPage ? COLORS.surfaceBase : "transparent",
borderBottom: scrolled || menuOpen || isProductPage ? `1px solid ${COLORS.border}` : "1px solid transparent",
          backdropFilter: "blur(18px)",
          WebkitBackdropFilter: "blur(18px)",
          transition: "background 0.3s ease, border-color 0.3s ease",
        }}
      >
        <div style={{ maxWidth: 1240, margin: "0 auto" }} className="flex items-center justify-between px-4 sm:px-6 md:px-10">
          <a
            href="#top"
            style={{
              fontFamily: FONT_DISPLAY,
              fontSize: 20,
              letterSpacing: "0.04em",
              color: navTextColor,
              display: "flex",
              alignItems: "center",
              gap: 8,
              padding: "16px 0",
            }}
          >
            <JewelArt type="ring" style={{ width: 22, height: 22 }} />
            Nyasa
          </a>

          {!isProductPage && (
            <nav className="hidden md:flex items-center" style={{ gap: 32 }}>
              {LINKS.map((c) => (
                <button
                  key={c}
                  onClick={() => scrollTo("shop")}
                  className="underline-grow"
                  style={{
                    background: "none",
                    border: "none",
                    fontSize: 14,
                    letterSpacing: "0.03em",
                    color: navTextColor,
                  }}
                >
                  {c}
                </button>
              ))}
              <button
                onClick={() => scrollTo("craft")}
                className="underline-grow"
                style={{ background: "none", border: "none", fontSize: 14, letterSpacing: "0.03em", color: navTextColor }}
              >
                The Craft
              </button>
               <button
                onClick={() => scrollTo("testimonials")}
                className="underline-grow"
                style={{ background: "none", border: "none", fontSize: 14, letterSpacing: "0.03em", color: navTextColor }}
              >
                Testimonials
              </button>
              <button
                onClick={() => scrollTo("faq")}
                className="underline-grow"
                style={{ background: "none", border: "none", fontSize: 14, letterSpacing: "0.03em", color: navTextColor }}
              >
                FAQ
              </button>
            </nav>
          )}

          <div className="flex items-center" style={{ gap: 10 }}>
            <button
              onClick={toggleTheme}
              aria-label={`Switch to ${nextThemeLabel} theme`}
              title={`Switch to ${nextThemeLabel} theme`}
              style={{
                width: 40,
                height: 40,
                borderRadius: 999,
                border: `1px solid ${scrolled || menuOpen ? COLORS.border : COLORS.toggleBorder}`,
                background: scrolled || menuOpen ? COLORS.surfaceSoft : COLORS.toggleSurface,
                color: navTextColor,
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                boxShadow: scrolled || menuOpen ? "none" : "0 8px 24px rgba(15, 23, 42, 0.12)",
                transition: "background 0.3s ease, border-color 0.3s ease, color 0.3s ease",
              }}
            >
              {themeMode === THEME_MODES.DARK ? <Sun size={18} strokeWidth={1.7} /> : <Moon size={18} strokeWidth={1.7} />}
            </button>
            <button
              onClick={() => setCartOpen(true)}
              aria-label="Open cart"
              style={{
                background: "none",
                border: "none",
                position: "relative",
                color: navTextColor,
                padding: 8,
              }}
            >
              <ShoppingBag size={20} strokeWidth={1.6} />
              {cartCount > 0 && (
                <span
                  className={bump ? "cart-badge-bump" : ""}
                  style={{
                    position: "absolute",
                    top: 2,
                    right: 2,
                    background: COLORS.rust,
                    color: COLORS.textOnStrong,
                    fontSize: 10,
                    width: 16,
                    height: 16,
                    borderRadius: "50%",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  {cartCount}
                </span>
              )}
            </button>
            {!isProductPage && (
              <button
                className="md:hidden"
                onClick={() => setMenuOpen((v) => !v)}
                aria-label="Toggle menu"
                aria-expanded={menuOpen}
                style={{ background: "none", border: "none", color: navTextColor, padding: 8, minHeight: 44 }}
              >
                {menuOpen ? <X size={22} strokeWidth={1.6} /> : <Menu size={22} strokeWidth={1.6} />}
              </button>
            )}
          </div>
        </div>
      </header>

      {/* Drawer — only relevant on the homepage, since it navigates to
          in-page sections (#shop, #craft, #faq) that don't exist on
          /product/:id. Hidden entirely on product pages. */}
      {!isProductPage && (
        <nav
          className="md:hidden"
          aria-hidden={!menuOpen}
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            width: 280,
            height: "100vh",
            background: DRAWER_BG,
            color: DRAWER_TEXT,
            zIndex: 1,
            overflowY: "auto",
            boxSizing: "border-box",
            borderRight: `1px solid ${DRAWER_BORDER}`,
            transform: menuOpen ? "translateX(0)" : "translateX(-100%)",
            transition: "transform 0.3s ease, background-color 0.35s ease, color 0.35s ease, border-color 0.35s ease",
            pointerEvents: menuOpen ? "auto" : "none",
          }}
        >
          <div className="flex items-center justify-between px-6" style={{ height: 64, borderBottom: `1px solid ${DRAWER_BORDER}` }}>
            <span style={{ fontSize: 13, letterSpacing: "0.08em", color: DRAWER_MUTED, textTransform: "uppercase", fontWeight: 600 }}>
              Menu
            </span>
            <button
              onClick={() => setMenuOpen(false)}
              aria-label="Close menu"
              tabIndex={menuOpen ? 0 : -1}
              style={{ background: "none", border: "none", color: DRAWER_TEXT, padding: 8 }}
            >
              <X size={20} strokeWidth={1.8} />
            </button>
          </div>

          <div className="flex flex-col px-6" style={{ paddingTop: 8 }}>
            {LINKS.map((c) => (
              <button key={c} onClick={() => handleDrawerNav("shop")} tabIndex={menuOpen ? 0 : -1} style={linkStyle}>
                {c}
              </button>
            ))}
            <button onClick={() => handleDrawerNav("craft")} tabIndex={menuOpen ? 0 : -1} style={linkStyle}>
              The Craft
            </button>
            <button onClick={() => handleDrawerNav("faq")} tabIndex={menuOpen ? 0 : -1} style={{ ...linkStyle, borderBottom: "none" }}>
              FAQ
            </button>
          </div>
        </nav>
      )}
    </>
  );
}