package com.myshop.nyasa_backend.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class CreateOrderRequest {

    @NotBlank(message = "Customer name is required")
    private String customerName;

    @NotBlank(message = "Phone number is required")
    private String phoneNumber;

    @NotBlank(message = "Delivery address is required")
    private String address;

    // Short-lived token returned by /api/auth/otp/verify, proves phoneNumber was OTP-verified
    @NotBlank(message = "Phone verification token is required")
    private String verificationToken;

    @NotEmpty(message = "Order must contain at least one item")
    @Valid
    private List<OrderItemRequest> items;
}
