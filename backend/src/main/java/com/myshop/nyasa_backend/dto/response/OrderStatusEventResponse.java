package com.myshop.nyasa_backend.dto.response;

import com.myshop.nyasa_backend.entity.OrderStatusHistory;
import com.myshop.nyasa_backend.enums.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderStatusEventResponse {

    private OrderStatus status;
    private String changedBy;
    private LocalDateTime createdAt;

    public static OrderStatusEventResponse from(OrderStatusHistory h) {
        return new OrderStatusEventResponse(h.getStatus(), h.getChangedBy(), h.getCreatedAt());
    }
}
