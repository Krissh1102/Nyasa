package com.myshop.nyasa_backend.dto.response;

import com.myshop.nyasa_backend.entity.Order;
import com.myshop.nyasa_backend.enums.OrderStatus;
import com.myshop.nyasa_backend.enums.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {

    private Long id;
    private String customerName;
    private String phoneNumber;
    private String address;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private PaymentStatus paymentStatus;
    private List<OrderItemResponse> items;
    private List<OrderStatusEventResponse> history;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static OrderResponse from(Order o) {
        return new OrderResponse(
                o.getId(),
                o.getCustomerName(),
                o.getPhoneNumber(),
                o.getAddress(),
                o.getTotalAmount(),
                o.getStatus(),
                o.getPaymentStatus(),
                o.getOrderItems().stream().map(OrderItemResponse::from).collect(Collectors.toList()),
                o.getStatusHistory().stream().map(OrderStatusEventResponse::from).collect(Collectors.toList()),
                o.getCreatedAt(),
                o.getUpdatedAt()
        );
    }
}
