package com.myshop.nyasa_backend.controller;

import com.myshop.nyasa_backend.dto.request.OtpRequestDto;
import com.myshop.nyasa_backend.dto.request.OtpVerifyDto;
import com.myshop.nyasa_backend.dto.response.ApiResponse;
import com.myshop.nyasa_backend.service.OtpService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth/otp")
@RequiredArgsConstructor
public class OtpController {

    private final OtpService otpService;

    @PostMapping("/request")
    public ApiResponse<Void> requestOtp(@Valid @RequestBody OtpRequestDto req) {
        otpService.requestOtp(req.getPhoneNumber());
        return ApiResponse.ok("OTP sent", null);
    }

    @PostMapping("/verify")
    public ApiResponse<Map<String, String>> verifyOtp(@Valid @RequestBody OtpVerifyDto req) {
        String token = otpService.verifyOtp(req.getPhoneNumber(), req.getOtp());
        // Client (React) stores this token and sends it back in CreateOrderRequest.verificationToken
        return ApiResponse.ok("Phone verified", Map.of("verificationToken", token));
    }
}
