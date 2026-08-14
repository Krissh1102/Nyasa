package com.myshop.nyasa_backend.service;

import com.myshop.nyasa_backend.entity.OtpVerification;
import com.myshop.nyasa_backend.exception.BadRequestException;
import com.myshop.nyasa_backend.repository.OtpVerificationRepository;
import com.myshop.nyasa_backend.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OtpService {

    private static final int OTP_LENGTH = 6;
    private static final int MAX_ATTEMPTS = 5;
    private static final SecureRandom RANDOM = new SecureRandom();

    private final OtpVerificationRepository otpRepository;
    private final SmsService smsService;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Value("${app.otp.expiry-minutes:5}")
    private int otpExpiryMinutes;

    @Value("${app.otp.resend-cooldown-seconds:30}")
    private int resendCooldownSeconds;

    @Transactional
    public void requestOtp(String phoneNumber) {
        otpRepository.findTopByPhoneNumberOrderByCreatedAtDesc(phoneNumber).ifPresent(last -> {
            if (last.getCreatedAt().plusSeconds(resendCooldownSeconds).isAfter(LocalDateTime.now())) {
                throw new BadRequestException("Please wait before requesting another OTP");
            }
        });

        String otp = generateOtp();

        OtpVerification record = OtpVerification.builder()
                .phoneNumber(phoneNumber)
                .otpHash(passwordEncoder.encode(otp))
                .expiresAt(LocalDateTime.now().plusMinutes(otpExpiryMinutes))
                .attempts(0)
                .verified(false)
                .build();
        otpRepository.save(record);

        smsService.sendOtp(phoneNumber, otp);
    }

    /** Returns a short-lived phone-verification token to be used at checkout. */
    @Transactional
    public String verifyOtp(String phoneNumber, String otp) {
        OtpVerification record = otpRepository.findTopByPhoneNumberOrderByCreatedAtDesc(phoneNumber)
                .orElseThrow(() -> new BadRequestException("No OTP requested for this phone number"));

        if (record.getVerified()) {
            throw new BadRequestException("OTP already used, please request a new one");
        }
        if (record.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new BadRequestException("OTP expired, please request a new one");
        }
        if (record.getAttempts() >= MAX_ATTEMPTS) {
            throw new BadRequestException("Too many incorrect attempts, please request a new OTP");
        }

        if (!passwordEncoder.matches(otp, record.getOtpHash())) {
            record.setAttempts(record.getAttempts() + 1);
            otpRepository.save(record);
            throw new BadRequestException("Incorrect OTP");
        }

        record.setVerified(true);
        otpRepository.save(record);

        return jwtUtil.generatePhoneVerificationToken(phoneNumber);
    }

    private String generateOtp() {
        int bound = (int) Math.pow(10, OTP_LENGTH);
        int value = RANDOM.nextInt(bound);
        return String.format("%0" + OTP_LENGTH + "d", value);
    }
}
