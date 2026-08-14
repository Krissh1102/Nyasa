package com.myshop.nyasa_backend.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Placeholder SMS provider. Swap this out for a real integration
 * (e.g. Twilio, MSG91, Gupshup) by implementing SmsService and
 * removing this bean, or by wiring credentials via application.yml.
 */
@Slf4j
@Service
public class ConsoleSmsService implements SmsService {

    @Override
    public void sendOtp(String phoneNumber, String otp) {
        log.info("[SMS STUB] Sending OTP {} to {}", otp, phoneNumber);
        // TODO: replace with a real SMS provider call, e.g.:
        // twilioClient.messages.create(to = phoneNumber, body = "Your OTP is " + otp, from = SENDER_ID)
    }
}
