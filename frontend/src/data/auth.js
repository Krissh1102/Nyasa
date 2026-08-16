import { BASE_URL } from "../constants/api";

async function post(path, body) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  let data = null;
  try {
    data = await res.json();
  } catch {
    // no body / non-JSON response
  }

  if (!res.ok || (data && data.success === false)) {
    const message = (data && data.message) || `Request failed (${res.status})`;
    throw new Error(message);
  }

  return data;
}

export const requestOtp = (phoneNumber) =>
  post("/api/auth/otp/request", { phoneNumber });

export const verifyOtp = (phoneNumber, otp) =>
  post("/api/auth/otp/verify", { phoneNumber, otp });