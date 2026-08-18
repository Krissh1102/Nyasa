package com.myshop.nyasa_backend.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // NOTE: Spring Security matches rules top-to-bottom, first match wins,
                        // so the specific write (POST/PUT/DELETE) rules must come BEFORE the
                        // broader permitAll GET rules for the same path.
                        .requestMatchers("/api/admin/auth/login").permitAll()
                        .requestMatchers("/actuator/health").permitAll()
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers(
        "/swagger-ui.html",
        "/swagger-ui/**",
        "/v3/api-docs",
        "/v3/api-docs/**"
).permitAll()

                        // Product/category writes require admin
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/products/**").hasAnyRole("ADMIN", "SUPER_ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/products/**").hasAnyRole("ADMIN", "SUPER_ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.DELETE, "/api/products/**").hasAnyRole("ADMIN", "SUPER_ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/categories/**").hasAnyRole("ADMIN", "SUPER_ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/categories/**").hasAnyRole("ADMIN", "SUPER_ADMIN")
                        .requestMatchers(org.springframework.http.HttpMethod.DELETE, "/api/categories/**").hasAnyRole("ADMIN", "SUPER_ADMIN")

                        // Public reads - React customer site
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/categories/**").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/products/**").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/orders").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/orders/**").permitAll()

                        // Flutter admin app - everything else under /api/admin/**
                        .requestMatchers("/api/admin/**").hasAnyRole("ADMIN", "SUPER_ADMIN", "STAFF")
                        .requestMatchers(
        org.springframework.http.HttpMethod.POST,
        "/api/images"
).hasAnyRole("ADMIN", "SUPER_ADMIN", "STAFF")

                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        // Tighten this to your real React domain + Flutter app origin in production
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
