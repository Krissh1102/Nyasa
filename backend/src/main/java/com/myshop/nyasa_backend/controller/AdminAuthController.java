package com.myshop.nyasa_backend.controller;

import com.myshop.nyasa_backend.dto.request.AdminLoginRequest;
import com.myshop.nyasa_backend.dto.response.ApiResponse;
import com.myshop.nyasa_backend.dto.response.JwtResponse;
import com.myshop.nyasa_backend.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/auth")
@RequiredArgsConstructor
public class AdminAuthController {

    private final AdminService adminService;

    /** Used by the Flutter admin app. */
    @PostMapping("/login")
    public ApiResponse<JwtResponse> login(@Valid @RequestBody AdminLoginRequest req) {
        return ApiResponse.ok(adminService.login(req));
    }
}
