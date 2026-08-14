package com.myshop.nyasa_backend.dto.response;

import com.myshop.nyasa_backend.entity.Product;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {

    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private Long categoryId;
    private String categoryName;
    private String imageUrl;
    private Boolean isActive;
    private Integer stockQuantity; // null if inventory row missing

    public static ProductResponse from(Product p, Integer stockQuantity) {
        return new ProductResponse(
                p.getId(),
                p.getName(),
                p.getDescription(),
                p.getPrice(),
                p.getCategory() != null ? p.getCategory().getId() : null,
                p.getCategory() != null ? p.getCategory().getName() : null,
                p.getImageUrl(),
                p.getIsActive(),
                stockQuantity
        );
    }
}
