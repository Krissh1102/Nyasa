package com.myshop.nyasa_backend.service;

import com.myshop.nyasa_backend.dto.request.ProductRequest;
import com.myshop.nyasa_backend.dto.response.ProductResponse;
import com.myshop.nyasa_backend.entity.Category;
import com.myshop.nyasa_backend.entity.Product;
import com.myshop.nyasa_backend.exception.ResourceNotFoundException;
import com.myshop.nyasa_backend.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final InventoryService inventoryService;
    private final CategoryService categoryService;

    @Transactional(readOnly = true)
    public Page<ProductResponse> list(Long categoryId, String search, Pageable pageable) {
        Page<Product> page;
        if (categoryId != null) {
            page = productRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable);
        } else if (search != null && !search.isBlank()) {
            page = productRepository.findByNameContainingIgnoreCaseAndIsActiveTrue(search, pageable);
        } else {
            page = productRepository.findByIsActiveTrue(pageable);
        }
        return page.map(p -> ProductResponse.from(p, inventoryService.getQuantityOrNull(p.getId())));
    }

    @Transactional(readOnly = true)
    public ProductResponse getById(Long id) {
        Product product = findEntity(id);
        return ProductResponse.from(product, inventoryService.getQuantityOrNull(id));
    }

    @Transactional(readOnly = true)
    public Product findEntity(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found with id " + id));
    }

    @Transactional
    public ProductResponse create(ProductRequest req) {
        Category category = categoryService.findEntity(req.getCategoryId());

        Product product = Product.builder()
                .name(req.getName())
                .description(req.getDescription())
                .price(req.getPrice())
                .category(category)
                .imageUrl(req.getImageUrl())
                .isActive(req.getIsActive() != null ? req.getIsActive() : true)
                .build();
        product = productRepository.save(product);

        inventoryService.createForProduct(product, req.getInitialQuantity(), req.getLowStockAt());

        return ProductResponse.from(product, inventoryService.getQuantityOrNull(product.getId()));
    }

    @Transactional
    public ProductResponse update(Long id, ProductRequest req) {
        Product product = findEntity(id);
        Category category = categoryService.findEntity(req.getCategoryId());

        product.setName(req.getName());
        product.setDescription(req.getDescription());
        product.setPrice(req.getPrice());
        product.setCategory(category);
        product.setImageUrl(req.getImageUrl());
        if (req.getIsActive() != null) {
            product.setIsActive(req.getIsActive());
        }
        product = productRepository.save(product);
        return ProductResponse.from(product, inventoryService.getQuantityOrNull(product.getId()));
    }

    @Transactional
    public void delete(Long id) {
        // Soft delete - keeps historical order_items referencing this product intact
        Product product = findEntity(id);
        product.setIsActive(false);
        productRepository.save(product);
    }
}
