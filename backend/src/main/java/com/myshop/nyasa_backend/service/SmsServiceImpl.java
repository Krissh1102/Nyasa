package com.myshop.nyasa_backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
@RequiredArgsConstructor
public class SmsServiceImpl implements SmsService {

    /*
     * ============================================================
     * 2FACTOR CONFIGURATION
     * ============================================================
     *
     * Add this to application.properties when you're ready:
     *
     * twofactor.api-key=${TWOFACTOR_API_KEY}
     *
     * And set:
     *
     * TWOFACTOR_API_KEY=your_api_key
     *
     * ============================================================
     */

    // @Value("${twofactor.api-key}")
    // private String apiKey;

    // private final RestClient restClient = RestClient.builder().build();


    @Override
    public void sendOtp(String phoneNumber, String otp) {

        /*
         * ============================================================
         * TEMPORARY DEVELOPMENT MODE
         * ============================================================
         *
         * For now, just print the OTP in your backend console.
         *
         * REMOVE THIS WHEN YOU ENABLE 2FACTOR.
         * ============================================================
         */

        System.out.println("====================================");
        System.out.println("DEV OTP");
        System.out.println("Phone : " + phoneNumber);
        System.out.println("OTP   : " + otp);
        System.out.println("====================================");


        /*
         * ============================================================
         * 2FACTOR OTP API
         * ============================================================
         *
         * Uncomment when you're ready.
         *
         * IMPORTANT:
         * Check the current 2Factor API documentation/dashboard
         * for the exact endpoint and parameters for your account.
         *
         * ============================================================
         */

        /*
        String url = "https://2factor.in/API/V1/"
                + apiKey
                + "/SMS/"
                + phoneNumber
                + "/"
                + otp
                + "/OTP1";

        try {

            String response = restClient.get()
                    .uri(url)
                    .retrieve()
                    .body(String.class);

            System.out.println("2Factor response: " + response);

        } catch (Exception e) {

            System.err.println("Failed to send OTP via 2Factor");
            System.err.println(e.getMessage());

            throw new RuntimeException("Unable to send OTP", e);
        }
        */
    }
}