import React from "react";
import { COLORS, FONT_DISPLAY } from "../constants/theme";

export default function Marquee() {
  return (
    <div 
      id="marquee" 
      style={{ 
        background: COLORS.surfaceAccent, 
        color: COLORS.textOnStrong, 
        overflow: "hidden", 
        padding: "16px 0" 
      }}
    >
      <style>
        {`
          .marquee-track {
            display: flex;
            width: max-content;
            /* Added animation for continuous scrolling */
            animation: scroll 20s linear infinite; 
          }
          
          .marquee-group {
            display: flex;
            gap: 40px; /* Fixed spacing between words */
            padding-right: 40px; /* Must match gap for seamless loop */
          }
          
          .marquee-item {
            font-family: ${FONT_DISPLAY};
            font-style: italic;
            font-size: 20px;
            white-space: nowrap;
          }

          @keyframes scroll {
            to {
              transform: translateX(-50%);
            }
          }

          /* Mobile Responsiveness */
          @media (max-width: 768px) {
            .marquee-group {
              gap: 24px;
              padding-right: 24px;
            }
            .marquee-item {
              font-size: 16px; /* Smaller font on mobile */
            }
          }
        `}
      </style>

      <div className="marquee-track">
        {[0, 1].map((k) => (
          <div key={k} className="marquee-group">
            {["Reclaimed metal", "Hand-set stones", "Made to order", "Lifetime repair", "Carved, not molded"].map((t) => (
              <span key={t} className="marquee-item">
                {t}
              </span>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}