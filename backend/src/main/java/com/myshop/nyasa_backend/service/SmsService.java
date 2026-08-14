package com.myshop.nyasa_backend.service;

public interface SmsService {
    void sendOtp(String phoneNumber, String otp);
}
