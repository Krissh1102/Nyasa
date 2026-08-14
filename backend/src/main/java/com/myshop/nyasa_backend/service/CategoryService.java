package com.myshop.nyasa_backend.service;

import com.myshop.nyasa_backend.dto.request.CategoryRequest;
import com.myshop.nyasa_backend.dto.response.CategoryResponse;
import com.myshop.nyasa_backend.entity.Category;
import com.myshop.nyasa_backend.exception.ResourceNotFoundException;
import com.myshop.nyasa_backend.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true)
    public List<CategoryResponse> getAllActive() {
        return categoryRepository.findByIsActiveTrue().stream()
                .map(CategoryResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CategoryResponse getById(Long id) {
        return CategoryResponse.from(findEntity(id));
    }

    @Transactional(readOnly = true)
    public Category findEntity(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with id " + id));
    }

    @Transactional
    public CategoryResponse create(CategoryRequest req) {
        Category category = Category.builder()
                .name(req.getName())
                .description(req.getDescription())
                .isActive(req.getIsActive() != null ? req.getIsActive() : true)
                .build();
        return CategoryResponse.from(categoryRepository.save(category));
    }

    @Transactional
    public CategoryResponse update(Long id, CategoryRequest req) {
        Category category = findEntity(id);
        category.setName(req.getName());
        category.setDescription(req.getDescription());
        if (req.getIsActive() != null) {
            category.setIsActive(req.getIsActive());
        }
        return CategoryResponse.from(categoryRepository.save(category));
    }

    @Transactional
    public void delete(Long id) {
        // Soft delete - keeps historical products/orders referencing this category intact
        Category category = findEntity(id);
        category.setIsActive(false);
        categoryRepository.save(category);
    }
}
