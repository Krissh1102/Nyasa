package com.myshop.nyasa_backend.service;

import com.myshop.nyasa_backend.dto.request.InventoryUpdateRequest;
import com.myshop.nyasa_backend.entity.Inventory;
import com.myshop.nyasa_backend.entity.Product;
import com.myshop.nyasa_backend.exception.BadRequestException;
import com.myshop.nyasa_backend.exception.ResourceNotFoundException;
import com.myshop.nyasa_backend.repository.InventoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InventoryService {

    private final InventoryRepository inventoryRepository;

    @Transactional
    public Inventory createForProduct(Product product, Integer initialQuantity, Integer lowStockAt) {
        Inventory inventory = Inventory.builder()
                .product(product)
                .quantity(initialQuantity != null ? initialQuantity : 0)
                .lowStockAt(lowStockAt != null ? lowStockAt : 5)
                .build();
        return inventoryRepository.save(inventory);
    }

    @Transactional(readOnly = true)
    public Inventory findByProductId(Long productId) {
        return inventoryRepository.findByProductId(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Inventory not found for product " + productId));
    }

    @Transactional(readOnly = true)
    public Integer getQuantityOrNull(Long productId) {
        return inventoryRepository.findByProductId(productId)
                .map(Inventory::getQuantity)
                .orElse(null);
    }

    @Transactional
    public Inventory update(Long productId, InventoryUpdateRequest req) {
        Inventory inventory = findByProductId(productId);
        if (req.getQuantity() < 0) {
            throw new BadRequestException("Quantity cannot be negative");
        }
        inventory.setQuantity(req.getQuantity());
        if (req.getLowStockAt() != null) {
            inventory.setLowStockAt(req.getLowStockAt());
        }
        return inventoryRepository.save(inventory);
    }

    /** Called by OrderService inside the order-creation transaction. Throws if stock is insufficient. */
    @Transactional
    public void reserveStock(Long productId, int quantity) {
        Inventory inventory = findByProductId(productId);
        if (inventory.getQuantity() < quantity) {
            throw new BadRequestException(
                    "Insufficient stock for product id " + productId +
                    " (requested " + quantity + ", available " + inventory.getQuantity() + ")");
        }
        inventory.setQuantity(inventory.getQuantity() - quantity);
        inventoryRepository.save(inventory);
    }

    @Transactional
    public void restock(Long productId, int quantity) {
        Inventory inventory = findByProductId(productId);
        inventory.setQuantity(inventory.getQuantity() + quantity);
        inventoryRepository.save(inventory);
    }

    @Transactional(readOnly = true)
    public List<Inventory> getLowStockItems() {
        return inventoryRepository.findLowStockItems();
    }
}
