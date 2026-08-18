import React, { useState, useRef, useEffect } from "react";
import { X, Plus, Minus, Check, ArrowLeft } from "lucide-react";
import JewelArt from "./JewelArt";
import { COLORS, FONT_DISPLAY } from "../constants/theme";
import { money } from "../utils/helpers";
import { requestOtp, verifyOtp } from "../data/auth";
import { placeOrderRequest } from "../data/order";

const STEP = {
  CART: "cart",
  DETAILS: "details",
  PHONE: "phone",
  OTP: "otp",
};

const STEP_ORDER = [STEP.CART, STEP.DETAILS, STEP.PHONE, STEP.OTP];
const RESEND_COOLDOWN_SECONDS = 30;

export default function CartDrawer({
  cartOpen,
  setCartOpen,
  cart = [],
  checkedOut,
  setCheckedOut,
  updateQty,
  removeItem,
  subtotal,
  onOrderPlaced,
}) {
  const [step, setStep] = useState(STEP.CART);
  const [direction, setDirection] = useState("forward");

  const [name, setName] = useState("");
  const [addressLine, setAddressLine] = useState("");
  const [city, setCity] = useState("");
  const [pincode, setPincode] = useState("");

  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState(["", "", "", "", "", ""]);
  const otpRefs = useRef([]);

  const [sendingOtp, setSendingOtp] = useState(false);
  const [otpSendError, setOtpSendError] = useState("");
  const [resendCooldown, setResendCooldown] = useState(0);

  const [verifying, setVerifying] = useState(false);
  const [verifyError, setVerifyError] = useState("");

  // id -> counter; >0 means "show warning + restart shake"
  const [stockWarnings, setStockWarnings] = useState({});
  const warningTimers = useRef({});

  useEffect(() => {
    if (resendCooldown <= 0) return;
    const timer = setTimeout(() => setResendCooldown((s) => s - 1), 1000);
    return () => clearTimeout(timer);
  }, [resendCooldown]);

  useEffect(() => {
    return () => {
      Object.values(warningTimers.current).forEach(clearTimeout);
    };
  }, []);

  const fullPhone = () => `+91${phone.replace(/\D/g, "")}`;

  const goToStep = (next) => {
    setDirection(STEP_ORDER.indexOf(next) > STEP_ORDER.indexOf(step) ? "forward" : "back");
    setStep(next);
  };

  const resetCheckoutFlow = () => {
    setStep(STEP.CART);
    setName("");
    setAddressLine("");
    setCity("");
    setPincode("");
    setPhone("");
    setOtp(["", "", "", "", "", ""]);
    setOtpSendError("");
    setVerifyError("");
    setResendCooldown(0);
  };

  const handleClose = () => {
    setCartOpen(false);
    setTimeout(() => {
      if (!checkedOut) resetCheckoutFlow();
    }, 350);
  };

  const handleOtpChange = (index, value) => {
    if (!/^[0-9]?$/.test(value)) return;
    const next = [...otp];
    next[index] = value;
    setOtp(next);
    if (value && index < otp.length - 1) {
      otpRefs.current[index + 1]?.focus();
    }
  };

  const handleOtpKeyDown = (index, e) => {
    if (e.key === "Backspace" && !otp[index] && index > 0) {
      otpRefs.current[index - 1]?.focus();
    }
  };

  const triggerItemWarning = (id) => {
    setStockWarnings((w) => ({ ...w, [id]: (w[id] || 0) + 1 }));
    clearTimeout(warningTimers.current[id]);
    warningTimers.current[id] = setTimeout(() => {
      setStockWarnings((w) => ({ ...w, [id]: 0 }));
    }, 2000);
  };

  // THE FIX: only call updateQty(+1) if we're still under stockQuantity
  const handleIncrementItem = (item) => {
    const max = typeof item.stockQuantity === "number" ? item.stockQuantity : Infinity;
    if (item.qty >= max) {
      triggerItemWarning(item.id);
      return;
    }
    updateQty(item.id, 1);
  };

  const detailsValid =
    name.trim().length >= 2 &&
    addressLine.trim().length >= 5 &&
    city.trim().length >= 2 &&
    pincode.replace(/\D/g, "").length >= 4;

  const phoneValid = phone.replace(/\D/g, "").length >= 10;
  const otpValid = otp.every((d) => d !== "");

  const handleSendOtp = async () => {
    if (!phoneValid || sendingOtp) return;
    setSendingOtp(true);
    setOtpSendError("");
    try {
      await requestOtp(fullPhone());
      setSendingOtp(false);
      setResendCooldown(RESEND_COOLDOWN_SECONDS);
      goToStep(STEP.OTP);
    } catch (e) {
      setSendingOtp(false);
      setOtpSendError(e.message || "Could not send code. Try again.");
    }
  };

  const handleResend = async () => {
    if (resendCooldown > 0 || sendingOtp) return;
    setSendingOtp(true);
    setOtpSendError("");
    try {
      await requestOtp(fullPhone());
      setResendCooldown(RESEND_COOLDOWN_SECONDS);
    } catch (e) {
      setOtpSendError(e.message || "Could not resend code. Try again.");
    } finally {
      setSendingOtp(false);
    }
  };

  const handleVerify = async () => {
    if (!otpValid || verifying) return;
    setVerifying(true);
    setVerifyError("");

    try {
      const verifyRes = await verifyOtp(fullPhone(), otp.join(""));
      const verificationToken = verifyRes?.data?.verificationToken ?? verifyRes?.verificationToken;
      if (!verificationToken) {
        throw new Error("Verification succeeded but no token was returned.");
      }

      const address = `${addressLine.trim()}, ${city.trim()} ${pincode.trim()}`;

      const orderPayload = {
        customerName: name.trim(),
        phoneNumber: fullPhone(),
        address,
        verificationToken,
        items: cart.map((item) => ({
          productId: item.id,
          quantity: item.qty,
        })),
      };

      const orderRes = await placeOrderRequest(orderPayload);

      if (onOrderPlaced) {
        onOrderPlaced({
          name: name.trim(),
          address: {
            line: addressLine.trim(),
            city: city.trim(),
            pincode: pincode.trim(),
          },
          phone: fullPhone(),
          items: cart,
          subtotal,
          placedAt: new Date().toISOString(),
          order: orderRes,
        });
      }

      setVerifying(false);
      setCheckedOut(true);
      setStep(STEP.CART);
    } catch (e) {
      setVerifying(false);
      setVerifyError(e.message || "Could not verify code. Try again.");
    }
  };

  const inputStyle = {
    width: "100%",
    background: COLORS.surfaceSoft,
    border: `1px solid ${COLORS.border}`,
    borderRadius: 12,
    color: COLORS.text,
    fontSize: 15,
    padding: "13px 14px",
    outline: "none",
    fontFamily: "inherit",
    transition: "border-color 0.2s ease, box-shadow 0.2s ease",
  };

  const labelStyle = {
    fontSize: 12,
    color: COLORS.textMuted,
    display: "block",
    marginBottom: 8,
  };

  const fieldWrapStyle = { marginBottom: 16 };

  const primaryButtonStyle = (disabled) => ({
    width: "100%",
    background: disabled ? COLORS.surfaceMuted : COLORS.surfaceStrong,
    color: disabled ? COLORS.textFaint : COLORS.textOnStrong,
    border: "none",
    borderRadius: 14,
    padding: "15px 0",
    fontSize: 14,
    letterSpacing: "0.03em",
    cursor: disabled ? "not-allowed" : "pointer",
    transition: "transform 0.15s ease, opacity 0.2s ease, background 0.2s ease",
  });

  const backButtonStyle = {
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    background: "none",
    border: "none",
    borderRadius: 999,
    color: COLORS.text,
    padding: 6,
    cursor: "pointer",
    transition: "background 0.2s ease, transform 0.15s ease",
  };

  const errorTextStyle = {
    fontSize: 12.5,
    color: "#c0392b",
    marginTop: 10,
  };

  const renderHeaderTitle = () => {
    if (step === STEP.DETAILS) return "Delivery details";
    if (step === STEP.PHONE) return "Enter phone number";
    if (step === STEP.OTP) return "Verify OTP";
    return "Your bag";
  };

  const slideOffset = direction === "forward" ? 24 : -24;

  return (
    <>
      <style>{`
        @keyframes drawerStepIn {
          from { opacity: 0; transform: translateX(${slideOffset}px); }
          to { opacity: 1; transform: translateX(0); }
        }
        @keyframes checkPop {
          0% { opacity: 0; transform: scale(0.6); }
          60% { opacity: 1; transform: scale(1.08); }
          100% { opacity: 1; transform: scale(1); }
        }
        @keyframes cdShake {
          0%, 100% { transform: translateX(0); }
          20% { transform: translateX(-5px); }
          40% { transform: translateX(4px); }
          60% { transform: translateX(-3px); }
          80% { transform: translateX(3px); }
        }
        @keyframes cdWarningIn {
          from { opacity: 0; transform: translateY(-4px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .cd-step {
          animation: drawerStepIn 0.32s cubic-bezier(0.22, 1, 0.36, 1);
        }
        .cd-primary-btn:not(:disabled):hover {
          transform: translateY(-1px);
          filter: brightness(1.05);
        }
        .cd-primary-btn:not(:disabled):active {
          transform: translateY(0) scale(0.985);
        }
        .cd-back-btn:hover {
          background: ${COLORS.surfaceSoft};
        }
        .cd-back-btn:active {
          transform: scale(0.92);
        }
        .cd-icon-btn {
          transition: background 0.2s ease, transform 0.15s ease;
          border-radius: 999px;
        }
        .cd-icon-btn:hover {
          background: ${COLORS.surfaceSoft};
        }
        .cd-icon-btn:active {
          transform: scale(0.92);
        }
        .cd-qty-btn {
          transition: background 0.2s ease;
        }
        .cd-qty-btn:hover {
          background: ${COLORS.surfaceSoft};
        }
        .cd-otp-box {
          transition: border-color 0.2s ease, transform 0.15s ease, box-shadow 0.2s ease;
        }
        .cd-otp-box:focus {
          transform: translateY(-2px);
          box-shadow: 0 4px 10px -4px ${COLORS.overlay};
        }
        .cd-input:focus {
          border-color: ${COLORS.verdigris} !important;
        }
        .cd-cart-row {
          transition: background 0.2s ease;
        }
        .cd-overlay {
          transition: opacity 0.35s ease;
        }
        .cd-qty-shake {
          animation: cdShake 0.4s ease;
        }
        .cd-stock-warning {
          animation: cdWarningIn 0.25s ease;
        }
      `}</style>

      <div
        onClick={handleClose}
        className="cd-overlay"
        style={{
          position: "fixed",
          inset: 0,
          background: COLORS.overlay,
          opacity: cartOpen ? 1 : 0,
          pointerEvents: cartOpen ? "auto" : "none",
          zIndex: 60,
        }}
      />
      <aside
        style={{
          position: "fixed",
          top: 0,
          right: 0,
          bottom: 0,
          width: "min(420px, 100vw)",
          background: COLORS.surfaceCard,
          zIndex: 61,
          transform: cartOpen ? "translateX(0)" : "translateX(100%)",
          transition: "transform 0.4s cubic-bezier(0.22, 1, 0.36, 1)",
          display: "flex",
          flexDirection: "column",
          borderRadius: "20px 0 0 20px",
          overflow: "hidden",
          boxShadow: cartOpen ? "-12px 0 40px -12px rgba(0,0,0,0.25)" : "none",
        }}
      >
        <div
          className="flex items-center justify-between"
          style={{ padding: "20px 22px", borderBottom: `1px solid ${COLORS.border}` }}
        >
          <div className="flex items-center" style={{ gap: 8 }}>
            {(step === STEP.DETAILS || step === STEP.PHONE || step === STEP.OTP) && (
              <button
                onClick={() =>
                  goToStep(
                    step === STEP.OTP ? STEP.PHONE : step === STEP.PHONE ? STEP.DETAILS : STEP.CART
                  )
                }
                className="cd-back-btn"
                style={backButtonStyle}
                aria-label="Go back"
              >
                <ArrowLeft size={18} />
              </button>
            )}
            <h3 key={step} className="cd-step" style={{ fontFamily: FONT_DISPLAY, fontSize: 20 }}>
              {renderHeaderTitle()}
            </h3>
          </div>
          <button
            onClick={handleClose}
            className="cd-icon-btn"
            style={{ background: "none", border: "none", color: COLORS.text, padding: 6 }}
            aria-label="Close cart"
          >
            <X size={20} />
          </button>
        </div>

        <div style={{ flex: 1, overflowY: "auto", padding: "10px 22px" }}>
          {checkedOut ? (
            <div style={{ textAlign: "center", padding: "60px 10px", animation: "drawerStepIn 0.4s cubic-bezier(0.22, 1, 0.36, 1)" }}>
              <div
                style={{
                  width: 56,
                  height: 56,
                  borderRadius: "50%",
                  background: COLORS.surfaceSoft,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  margin: "0 auto 16px",
                  animation: "checkPop 0.5s cubic-bezier(0.22, 1, 0.36, 1)",
                }}
              >
                <Check size={26} color={COLORS.verdigris} />
              </div>
              <p style={{ fontFamily: FONT_DISPLAY, fontSize: 20, marginBottom: 8 }}>Order placed</p>
              <p style={{ fontSize: 14, color: COLORS.textMuted }}>
                A confirmation is on its way to your inbox. Thank you for choosing reclaimed gold.
              </p>
            </div>
          ) : step === STEP.DETAILS ? (
            <div key="details" className="cd-step" style={{ padding: "24px 0" }}>
              <p style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 18 }}>
                Tell us where to deliver your order.
              </p>

              <div style={fieldWrapStyle}>
                <label style={labelStyle}>Full name</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Aditi Sharma"
                  className="cd-input"
                  style={inputStyle}
                  autoFocus
                />
              </div>

              <div style={fieldWrapStyle}>
                <label style={labelStyle}>Address</label>
                <input
                  type="text"
                  value={addressLine}
                  onChange={(e) => setAddressLine(e.target.value)}
                  placeholder="House no., street, area"
                  className="cd-input"
                  style={inputStyle}
                />
              </div>

              <div className="flex items-center" style={{ gap: 12 }}>
                <div style={{ ...fieldWrapStyle, flex: 1.4 }}>
                  <label style={labelStyle}>City</label>
                  <input
                    type="text"
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    placeholder="Pune"
                    className="cd-input"
                    style={inputStyle}
                  />
                </div>
                <div style={{ ...fieldWrapStyle, flex: 1 }}>
                  <label style={labelStyle}>Pincode</label>
                  <input
                    type="text"
                    inputMode="numeric"
                    value={pincode}
                    onChange={(e) => setPincode(e.target.value.replace(/\D/g, ""))}
                    placeholder="411001"
                    maxLength={6}
                    className="cd-input"
                    style={inputStyle}
                  />
                </div>
              </div>
            </div>
          ) : step === STEP.PHONE ? (
            <div key="phone" className="cd-step" style={{ padding: "24px 0" }}>
              <p style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 18 }}>
                We'll text you a one-time code to confirm your order.
              </p>
              <label style={labelStyle}>Phone number</label>
              <div
                className="flex items-center"
                style={{
                  border: `1px solid ${COLORS.border}`,
                  background: COLORS.surfaceSoft,
                  borderRadius: 12,
                  overflow: "hidden",
                }}
              >
                <span
                  style={{
                    padding: "13px 12px",
                    fontSize: 15,
                    color: COLORS.textMuted,
                    borderRight: `1px solid ${COLORS.border}`,
                  }}
                >
                  +91
                </span>
                <input
                  type="tel"
                  inputMode="numeric"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value.replace(/[^\d\s]/g, ""))}
                  placeholder="98765 43210"
                  style={{ ...inputStyle, border: "none", background: "transparent", borderRadius: 0 }}
                  autoFocus
                />
              </div>
              {otpSendError && <p style={errorTextStyle}>{otpSendError}</p>}
            </div>
          ) : step === STEP.OTP ? (
            <div key="otp" className="cd-step" style={{ padding: "24px 0" }}>
              <p style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 4 }}>
                Enter the 6-digit code sent to
              </p>
              <p style={{ fontSize: 14, color: COLORS.text, marginBottom: 22 }}>+91 {phone}</p>
              <div className="flex items-center justify-between" style={{ gap: 8 }}>
                {otp.map((digit, i) => (
                  <input
                    key={i}
                    ref={(el) => (otpRefs.current[i] = el)}
                    type="text"
                    inputMode="numeric"
                    maxLength={1}
                    value={digit}
                    onChange={(e) => handleOtpChange(i, e.target.value)}
                    onKeyDown={(e) => handleOtpKeyDown(i, e)}
                    className="cd-otp-box"
                    style={{
                      width: 44,
                      height: 52,
                      textAlign: "center",
                      fontSize: 18,
                      background: COLORS.surfaceSoft,
                      border: `1px solid ${digit ? COLORS.verdigris : COLORS.border}`,
                      borderRadius: 12,
                      color: COLORS.text,
                      outline: "none",
                    }}
                    autoFocus={i === 0}
                    disabled={verifying}
                  />
                ))}
              </div>
              {verifyError && <p style={errorTextStyle}>{verifyError}</p>}
              <button
                onClick={handleResend}
                disabled={resendCooldown > 0 || sendingOtp}
                style={{
                  background: "none",
                  border: "none",
                  color: resendCooldown > 0 || sendingOtp ? COLORS.textFaint : COLORS.verdigris,
                  fontSize: 12.5,
                  padding: 0,
                  marginTop: 18,
                  cursor: resendCooldown > 0 || sendingOtp ? "not-allowed" : "pointer",
                }}
              >
                {resendCooldown > 0 ? `Resend code (${resendCooldown}s)` : "Resend code"}
              </button>
            </div>
          ) : cart.length === 0 ? (
            <div className="cd-step" style={{ textAlign: "center", padding: "60px 10px" }}>
              <p style={{ fontSize: 14, color: COLORS.textSoft }}>Your bag is empty - for now.</p>
            </div>
          ) : (
            <div key="cart" className="cd-step">
              {cart.map((item) => {
                const max = typeof item.stockQuantity === "number" ? item.stockQuantity : Infinity;
                const warningCount = stockWarnings[item.id] || 0;
                return (
                  <div
                    key={item.id}
                    className="flex cd-cart-row"
                    style={{
                      gap: 14,
                      padding: "16px 8px",
                      margin: "0 -8px",
                      borderBottom: `1px solid ${COLORS.border}`,
                      borderRadius: 12,
                    }}
                  >
                    <div
                      style={{
                        width: 64,
                        height: 64,
                        background: COLORS.surfaceSoft,
                        borderRadius: 14,
                        flexShrink: 0,
                        overflow: "hidden",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                      }}
                    >
                      {item.imageUrl?.length > 0 ? (
                        <img
                          src={item.imageUrl[0]}
                          alt={item.name}
                          style={{
                            width: "100%",
                            height: "100%",
                            objectFit: "cover",
                            display: "block",
                          }}
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }}
                        />
                      ) : (
                        <JewelArt
                          type={item.art}
                          style={{
                            width: "60%",
                            color: COLORS.verdigris,
                          }}
                        />
                      )}
                    </div>
                    <div style={{ flex: 1 }}>
                      <div className="flex items-start justify-between">
                        <div>
                          <p style={{ fontFamily: FONT_DISPLAY, fontSize: 15 }}>{item.name}</p>
                          <p style={{ fontSize: 12, color: COLORS.textSoft }}>{item.material}</p>
                        </div>
                        <button
                          onClick={() => removeItem(item.id)}
                          className="cd-icon-btn"
                          style={{ background: "none", border: "none", color: COLORS.textFaint, padding: 4 }}
                          aria-label={`Remove ${item.name}`}
                        >
                          <X size={15} />
                        </button>
                      </div>
                      <div className="flex items-center justify-between" style={{ marginTop: 10 }}>
                        <div
                          key={warningCount}
                          className={`flex items-center ${warningCount ? "cd-qty-shake" : ""}`}
                          style={{ border: `1px solid ${COLORS.border}`, borderRadius: 10, overflow: "hidden" }}
                        >
                          <button
                            onClick={() => updateQty(item.id, -1)}
                            className="cd-qty-btn"
                            style={{ background: "none", border: "none", padding: "4px 8px", color: COLORS.text }}
                            aria-label="Decrease quantity"
                          >
                            <Minus size={12} />
                          </button>
                          <span style={{ fontSize: 13, minWidth: 18, textAlign: "center" }}>{item.qty}</span>
                          <button
                            onClick={() => handleIncrementItem(item)}
                            className="cd-qty-btn"
                            style={{ background: "none", border: "none", padding: "4px 8px", color: COLORS.text }}
                            aria-label="Increase quantity"
                          >
                            <Plus size={12} />
                          </button>
                        </div>
                        <span style={{ fontSize: 14 }}>{money(item.price * item.qty)}</span>
                      </div>
                      {warningCount > 0 && (
                        <p className="cd-stock-warning" style={{ fontSize: 11.5, color: "#c0392b", marginTop: 6 }}>
                          Only {max} available
                        </p>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {!checkedOut && step === STEP.CART && cart.length > 0 && (
          <div className="cd-step" style={{ padding: "20px 22px", borderTop: `1px solid ${COLORS.border}` }}>
            <div className="flex items-center justify-between" style={{ marginBottom: 16 }}>
              <span style={{ fontSize: 14, color: COLORS.textMuted }}>Subtotal</span>
              <span style={{ fontFamily: FONT_DISPLAY, fontSize: 20 }}>{money(subtotal)}</span>
            </div>
            <button onClick={() => goToStep(STEP.DETAILS)} className="cd-primary-btn" style={primaryButtonStyle(false)}>
              Checkout
            </button>
            <p style={{ fontSize: 11.5, color: COLORS.textFaint, marginTop: 10, textAlign: "center" }}>
              Shipping and duties calculated at checkout.
            </p>
          </div>
        )}

        {!checkedOut && step === STEP.DETAILS && (
          <div className="cd-step" style={{ padding: "20px 22px", borderTop: `1px solid ${COLORS.border}` }}>
            <button
              onClick={() => goToStep(STEP.PHONE)}
              disabled={!detailsValid}
              className="cd-primary-btn"
              style={primaryButtonStyle(!detailsValid)}
            >
              Continue
            </button>
          </div>
        )}

        {!checkedOut && step === STEP.PHONE && (
          <div className="cd-step" style={{ padding: "20px 22px", borderTop: `1px solid ${COLORS.border}` }}>
            <button
              onClick={handleSendOtp}
              disabled={!phoneValid || sendingOtp}
              className="cd-primary-btn"
              style={primaryButtonStyle(!phoneValid || sendingOtp)}
            >
              {sendingOtp ? "Sending..." : "Send OTP"}
            </button>
          </div>
        )}

        {!checkedOut && step === STEP.OTP && (
          <div className="cd-step" style={{ padding: "20px 22px", borderTop: `1px solid ${COLORS.border}` }}>
            <button
              onClick={handleVerify}
              disabled={!otpValid || verifying}
              className="cd-primary-btn"
              style={primaryButtonStyle(!otpValid || verifying)}
            >
              {verifying ? "Verifying..." : "Verify & place order"}
            </button>
          </div>
        )}
      </aside>
    </>
  );
}