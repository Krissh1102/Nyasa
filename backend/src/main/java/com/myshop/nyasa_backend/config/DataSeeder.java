package com.myshop.nyasa_backend.config;

import com.myshop.nyasa_backend.entity.Admin;
import com.myshop.nyasa_backend.enums.AdminRole;
import com.myshop.nyasa_backend.repository.AdminRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Creates a first SUPER_ADMIN account on startup if none exists yet, so you
 * can log in to the Flutter admin app immediately. Configure credentials via
 * app.seed.admin-email / app.seed.admin-password (see application.yml) -
 * change the password after first login, or remove this class once you have
 * a real admin management flow.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.seed.admin-email:admin@shop.com}")
    private String seedAdminEmail;

    @Value("${app.seed.admin-password:ChangeMe123!}")
    private String seedAdminPassword;

    @Override
    public void run(String... args) {
        if (!adminRepository.existsByEmail(seedAdminEmail)) {
            Admin admin = Admin.builder()
                    .name("Super Admin")
                    .email(seedAdminEmail)
                    .passwordHash(passwordEncoder.encode(seedAdminPassword))
                    .role(AdminRole.SUPER_ADMIN)
                    .isActive(true)
                    .build();
            adminRepository.save(admin);
            log.info("Seeded default admin account: {} (change the password after first login)", seedAdminEmail);
        }
    }
}
