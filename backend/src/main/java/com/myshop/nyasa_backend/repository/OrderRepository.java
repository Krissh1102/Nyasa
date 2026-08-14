package com.myshop.nyasa_backend.repository;

import com.myshop.nyasa_backend.entity.Order;
import com.myshop.nyasa_backend.enums.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    Page<Order> findByPhoneNumber(String phoneNumber, Pageable pageable);

    // Used for guest order tracking: an order id is only shown to someone who also knows the phone number
    Optional<Order> findByIdAndPhoneNumber(Long id, String phoneNumber);
}
