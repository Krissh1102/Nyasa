import { useEffect, useState } from "react";
import { THEME_MODES } from "../constants/theme";

function getCurrentTheme() {
  return document.documentElement.getAttribute("data-theme") === THEME_MODES.DARK
    ? THEME_MODES.DARK
    : THEME_MODES.LIGHT;
}

export function useThemeMode() {
  const [theme, setTheme] = useState(getCurrentTheme);

  useEffect(() => {
    const observer = new MutationObserver(() => setTheme(getCurrentTheme()));
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-theme"],
    });
    return () => observer.disconnect();
  }, []);

  return theme; // "light" | "dark"
}