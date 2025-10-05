package com.example.inventoryservice.controller;

import com.example.inventoryservice.dto.InventoryResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;
@Slf4j
@RestController
@RequestMapping("/inventory")
public class InventoryController {
    private static final Map<Long, Integer> inventory = new HashMap<>();
    private static final Random random = new Random();
    static {
        // Initialize with sample inventory data
        inventory.put(1L, 100);  // Laptop - 100 in stock
        inventory.put(2L, 250);  // Mouse - 250 in stock
        inventory.put(3L, 50);   // Keyboard - 50 in stock
        inventory.put(4L, 0);    // Out of stock item
    }
    @GetMapping("/{productId}")
    public InventoryResponse getInventory(@PathVariable Long productId) {
        log.info("Checking inventory for product: {}", productId);

        // Simulate some processing time
        try {
            Thread.sleep(random.nextInt(100));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        Integer quantity = inventory.getOrDefault(productId, 0);
        log.info("Product {} has {} items in stock", productId, quantity);

        return new InventoryResponse(productId, quantity);
    }
    @PutMapping("/{productId}")
    public InventoryResponse updateInventory(@PathVariable Long productId,
                                             @RequestParam Integer quantity) {
        log.info("Updating inventory for product {}: {} items", productId, quantity);
        inventory.put(productId, quantity);
        return new InventoryResponse(productId, quantity);
    }
    @GetMapping("/health")
    public String health() {
        return "Inventory Service is running! Port: " +
                System.getProperty("server.port", "8082");
    }
}