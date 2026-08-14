package com.myshop.nyasa_backend.controller;

import com.myshop.nyasa_backend.dto.request.CreateOrderRequest;
import com.myshop.nyasa_backend.dto.response.ApiResponse;
import com.myshop.nyasa_backend.dto.response.OrderResponse;
import com.myshop.nyasa_backend.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    /** Guest checkout - no login required, but requires an OTP-verified phone token. */
    @PostMapping
    public ApiResponse<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest req) {
        return ApiResponse.ok("Order placed", orderService.createOrder(req));
    }

    /** Guest order tracking - must supply the phone number the order was placed with. */
    @GetMapping("/{id}")
    public ApiResponse<OrderResponse> trackOrder(@PathVariable Long id, @RequestParam String phoneNumber) {
        return ApiResponse.ok(orderService.trackOrder(id, phoneNumber));
    }
}
