import React, { useState, useEffect, useCallback } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import "./styles/global.css";

import Nav from "./components/Nav";
import Footer from "./components/Footer";
import CartDrawer from "./components/CartDrawer";

import Home from "./pages/Home";
import ProductDetail from "./pages/ProductDetail";
import NotFound from "./pages/NotFound";

import { COLORS, FONT_BODY, THEME_MODES, THEME_STORAGE_KEY } from "./constants/theme";

const CART_STORAGE_KEY = "nyasa-cart";
const ORDERS_STORAGE_KEY = "nyasa-orders"; // admin backup — local record of placed orders

const getInitialThemeMode = () => {
  if (typeof window === "undefined") return THEME_MODES.LIGHT;

  const storedTheme = window.localStorage.getItem(THEME_STORAGE_KEY);
  if (storedTheme === THEME_MODES.LIGHT || storedTheme === THEME_MODES.DARK) {
    return storedTheme;
  }

  const mediaQuery =
    typeof window.matchMedia === "function"
      ? window.matchMedia("(prefers-color-scheme: dark)")
      : null;

  return mediaQuery?.matches ? THEME_MODES.DARK : THEME_MODES.LIGHT;
};

const getInitialCart = () => {
  if (typeof window === "undefined") return [];
  try {
    const saved = window.localStorage.getItem(CART_STORAGE_KEY);
    return saved ? JSON.parse(saved) : [];
  } catch {
    return [];
  }
};

export default function App() {
  const [themeMode, setThemeMode] = useState(getInitialThemeMode);
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [cartOpen, setCartOpen] = useState(false);
  const [cart, setCart] = useState(getInitialCart);
  const [filter, setFilter] = useState("All");
  const [checkedOut, setCheckedOut] = useState(false);
  const [bump, setBump] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", themeMode);
    window.localStorage.setItem(THEME_STORAGE_KEY, themeMode);
  }, [themeMode]);

  // Persist cart to localStorage whenever it changes
  useEffect(() => {
    try {
      window.localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
    } catch {
      // storage full or unavailable — cart still works in-memory
    }
  }, [cart]);

  const addToCart = useCallback((product) => {
    setCart((prev) => {
      const found = prev.find((i) => i.id === product.id);
      if (found) {
        return prev.map((i) => (i.id === product.id ? { ...i, qty: i.qty + 1 } : i));
      }
      return [...prev, { ...product, qty: 1 }];
    });
    setBump(true);
    setTimeout(() => setBump(false), 400);
  }, []);

  const updateQty = (id, delta) => {
    setCart((prev) =>
      prev
        .map((i) => (i.id === id ? { ...i, qty: Math.max(0, i.qty + delta) } : i))
        .filter((i) => i.qty > 0)
    );
  };

  const removeItem = (id) => setCart((prev) => prev.filter((i) => i.id !== id));

  const handleOrderPlaced = (orderData) => {
    try {
      const existing = window.localStorage.getItem(ORDERS_STORAGE_KEY);
      const orders = existing ? JSON.parse(existing) : [];
      const orderWithId = {
        id: `ORD-${Date.now()}`,
        ...orderData,
      };
      window.localStorage.setItem(
        ORDERS_STORAGE_KEY,
        JSON.stringify([...orders, orderWithId])
      );
    } catch {
      // storage full or unavailable — order still completes, just isn't backed up locally
    }
  };

  // Clear the cart once an order is successfully placed
  const handleSetCheckedOut = (value) => {
    setCheckedOut(value);
    if (value) {
      setCart([]);
    }
  };

  const cartCount = cart.reduce((sum, i) => sum + i.qty, 0);
  const subtotal = cart.reduce((sum, i) => sum + i.qty * i.price, 0);

  const scrollTo = (id) => {
    setMenuOpen(false);
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: "smooth", block: "start" });
  };

  const toggleTheme = useCallback(() => {
    setThemeMode((current) =>
      current === THEME_MODES.DARK ? THEME_MODES.LIGHT : THEME_MODES.DARK
    );
  }, []);

  return (
    <BrowserRouter>
      <div
        style={{
          fontFamily: FONT_BODY,
          background: COLORS.surfaceBase,
          color: COLORS.text,
          position: "relative",
          minHeight: "100vh",
        }}
      >
        <div className="nyasa-root">
          <Nav
            scrolled={scrolled}
            menuOpen={menuOpen}
            setMenuOpen={setMenuOpen}
            cartOpen={cartOpen}
            setCartOpen={setCartOpen}
            cartCount={cartCount}
            bump={bump}
            scrollTo={scrollTo}
            setFilter={setFilter}
            themeMode={themeMode}
            toggleTheme={toggleTheme}
          />

          <Routes>
            <Route
              path="/"
              element={
                <Home filter={filter} setFilter={setFilter} addToCart={addToCart} scrollTo={scrollTo} />
              }
            />
            <Route path="/product/:id" element={<ProductDetail addToCart={addToCart} />} />
            <Route path="*" element={<NotFound />} />
          </Routes>

          <Footer setFilter={setFilter} scrollTo={scrollTo} />

          <CartDrawer
            cartOpen={cartOpen}
            setCartOpen={setCartOpen}
            cart={cart}
            checkedOut={checkedOut}
            setCheckedOut={handleSetCheckedOut}
            updateQty={updateQty}
            removeItem={removeItem}
            subtotal={subtotal}
            onOrderPlaced={handleOrderPlaced}
          />
        </div>
      </div>
    </BrowserRouter>
  );
}