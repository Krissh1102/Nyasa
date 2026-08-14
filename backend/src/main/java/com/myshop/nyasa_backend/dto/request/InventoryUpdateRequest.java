package com.myshop.nyasa_backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InventoryUpdateRequest {

    @NotNull(message = "Quantity is required")
    private Integer quantity;

    private Integer lowStockAt;
}
