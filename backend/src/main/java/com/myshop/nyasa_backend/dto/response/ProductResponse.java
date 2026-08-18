package com.myshop.nyasa_backend.dto.response;

import com.myshop.nyasa_backend.entity.Product;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {

    private Long id;
    private String name;
    private String description;
    private BigDecimal weightGrams;
    private BigDecimal price;
    private Long categoryId;
    private String categoryName;
    private List<String>  imageUrl;
    private Boolean isActive;
    private Integer stockQuantity; 

    public static ProductResponse from(Product p, Integer stockQuantity) {
        return new ProductResponse(
            
                p.getId(),
                p.getName(),
                p.getDescription(),
                p.getWeightGrams(),
                p.getPrice(),
                p.getCategory() != null ? p.getCategory().getId() : null,
                p.getCategory() != null ? p.getCategory().getName() : null,
                p.getImageUrls(),
                p.getIsActive(),
                stockQuantity
        );
    }
}
