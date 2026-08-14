package com.myshop.nyasa_backend.service;

import com.myshop.nyasa_backend.dto.request.AdminLoginRequest;
import com.myshop.nyasa_backend.dto.response.JwtResponse;
import com.myshop.nyasa_backend.entity.Admin;
import com.myshop.nyasa_backend.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.myshop.nyasa_backend.repository.AdminRepository;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Transactional(readOnly = true)
    public JwtResponse login(AdminLoginRequest req) {
        Admin admin = adminRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));

        if (!admin.getIsActive()) {
            throw new BadCredentialsException("This admin account is disabled");
        }

        if (!passwordEncoder.matches(req.getPassword(), admin.getPasswordHash())) {
            throw new BadCredentialsException("Invalid email or password");
        }

        String token = jwtUtil.generateAdminToken(admin.getEmail(), admin.getRole().name());
        return new JwtResponse(token, admin.getName(), admin.getEmail(), admin.getRole().name());
    }
}
