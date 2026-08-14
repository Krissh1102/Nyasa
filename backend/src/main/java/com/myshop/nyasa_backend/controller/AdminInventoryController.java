package com.myshop.nyasa_backend.controller;

import com.myshop.nyasa_backend.dto.request.InventoryUpdateRequest;
import com.myshop.nyasa_backend.dto.response.ApiResponse;
import com.myshop.nyasa_backend.entity.Inventory;
import com.myshop.nyasa_backend.service.InventoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Used by the Flutter admin app. Requires an admin JWT (see SecurityConfig). */
@RestController
@RequestMapping("/api/admin/inventory")
@RequiredArgsConstructor
public class AdminInventoryController {

    private final InventoryService inventoryService;

    @GetMapping("/low-stock")
    public ApiResponse<List<Inventory>> lowStock() {
        return ApiResponse.ok(inventoryService.getLowStockItems());
    }

    @PutMapping("/{productId}")
    public ApiResponse<Inventory> update(@PathVariable Long productId, @Valid @RequestBody InventoryUpdateRequest req) {
        return ApiResponse.ok("Inventory updated", inventoryService.update(productId, req));
    }
}
