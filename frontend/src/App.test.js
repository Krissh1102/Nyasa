import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import App from "./App";

beforeEach(() => {
  window.localStorage.clear();
  document.documentElement.removeAttribute("data-theme");
});

test("toggles the app theme from the app bar", async () => {
  render(<App />);

  expect(document.documentElement).toHaveAttribute("data-theme", "light");

  const darkModeButton = screen.getByRole("button", { name: /switch to dark theme/i });
  await userEvent.click(darkModeButton);

  expect(document.documentElement).toHaveAttribute("data-theme", "dark");
  expect(screen.getByRole("button", { name: /switch to light theme/i })).toBeInTheDocument();
});
