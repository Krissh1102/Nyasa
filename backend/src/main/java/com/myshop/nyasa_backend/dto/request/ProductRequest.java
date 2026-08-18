package com.myshop.nyasa_backend.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ProductRequest {

    @NotBlank(message = "Product name is required")
    private String name;

    private String description;

    @NotNull(message = "Price is required")
    @DecimalMin(
        value = "0.0",
        inclusive = true,
        message = "Price cannot be negative"
    )
    private BigDecimal price;

    @NotNull(message = "Category id is required")
    private Long categoryId;

    @Size(max = 10, message = "A product can have at most 10 images")
    private List<String> imageUrls;

    @DecimalMin(
        value = "0.0",
        inclusive = true,
        message = "Weight cannot be negative"
    )
    private BigDecimal weightGrams;

    private Boolean isActive;

    // Optional: set initial stock when creating a product
    private Integer initialQuantity;

    private Integer lowStockAt;
}