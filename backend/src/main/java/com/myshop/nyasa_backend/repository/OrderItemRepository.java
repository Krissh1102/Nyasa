package com.myshop.nyasa_backend.repository;

import com.myshop.nyasa_backend.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
}
