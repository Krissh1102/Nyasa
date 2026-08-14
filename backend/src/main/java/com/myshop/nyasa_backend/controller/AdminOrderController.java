package com.myshop.nyasa_backend.controller;

import com.myshop.nyasa_backend.dto.request.UpdateOrderStatusRequest;
import com.myshop.nyasa_backend.dto.response.ApiResponse;
import com.myshop.nyasa_backend.dto.response.OrderResponse;
import com.myshop.nyasa_backend.enums.OrderStatus;
import com.myshop.nyasa_backend.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/** Used by the Flutter admin app. Requires an admin JWT (see SecurityConfig). */
@RestController
@RequestMapping("/api/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final OrderService orderService;

    @GetMapping
    public ApiResponse<Page<OrderResponse>> list(
            @RequestParam(required = false) OrderStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        return ApiResponse.ok(orderService.list(status, pageable));
    }

    @GetMapping("/{id}")
    public ApiResponse<OrderResponse> getById(@PathVariable Long id) {
        return ApiResponse.ok(orderService.getById(id));
    }

    @PutMapping("/{id}/status")
    public ApiResponse<OrderResponse> updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdateOrderStatusRequest req,
            Authentication authentication
    ) {
        String changedBy = authentication.getName(); // admin's email, set by JwtAuthFilter
        return ApiResponse.ok("Order status updated", orderService.updateStatus(id, req, changedBy));
    }
}
