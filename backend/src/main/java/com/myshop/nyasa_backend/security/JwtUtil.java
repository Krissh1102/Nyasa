package com.myshop.nyasa_backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtUtil {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.admin-expiration-ms}")
    private long adminExpirationMs;

    @Value("${app.jwt.otp-token-expiration-ms}")
    private long otpTokenExpirationMs;

    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    /** Token issued to an authenticated ADMIN (Flutter admin app). */
    public String generateAdminToken(String email, String role) {
        return Jwts.builder()
                .subject(email)
                .claims(Map.of("type", "ADMIN", "role", role))
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + adminExpirationMs))
                .signWith(key())
                .compact();
    }

    /**
     * Short-lived token issued after a phone number passes OTP verification.
     * The order-creation endpoint requires this token so a guest can only place
     * an order for a phone number they've actually proven they control.
     */
    public String generatePhoneVerificationToken(String phoneNumber) {
        return Jwts.builder()
                .subject(phoneNumber)
                .claims(Map.of("type", "PHONE_VERIFIED"))
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + otpTokenExpirationMs))
                .signWith(key())
                .compact();
    }

    public Claims parseClaims(String token) {
        return Jwts.parser().verifyWith(key()).build().parseSignedClaims(token).getPayload();
    }

    public <T> T extractClaim(String token, Function<Claims, T> resolver) {
        return resolver.apply(parseClaims(token));
    }

    public String extractSubject(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public String extractType(String token) {
        return extractClaim(token, c -> c.get("type", String.class));
    }

    public boolean isValid(String token) {
        try {
            Claims claims = parseClaims(token);
            return claims.getExpiration().after(new Date());
        } catch (Exception e) {
            return false;
        }
    }

    /** Validates that a token is an unexpired PHONE_VERIFIED token for the given phone number. */
    public boolean isValidPhoneToken(String token, String phoneNumber) {
        try {
            Claims claims = parseClaims(token);
            boolean typeOk = "PHONE_VERIFIED".equals(claims.get("type", String.class));
            boolean subjectOk = phoneNumber.equals(claims.getSubject());
            boolean notExpired = claims.getExpiration().after(new Date());
            return typeOk && subjectOk && notExpired;
        } catch (Exception e) {
            return false;
        }
    }
}
