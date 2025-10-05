package com.example.productservice.controller;

import com.example.productservice.dto.InventoryResponse;
import com.example.productservice.dto.ProductResponse;
import com.example.productservice.model.Product;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
@Slf4j
@RestController
@RequestMapping("/products")
public class ProductController {
    private final RestTemplate restTemplate;
    private static final Map<Long, Product> products = new HashMap<>();
    static {
        products.put(1L, new Product(1L, "Laptop", 999.99));
        products.put(2L, new Product(2L, "Mouse", 29.99));
        products.put(3L, new Product(3L, "Keyboard", 79.99));
    }
    public ProductController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }
    @GetMapping("/{id}")
    public ProductResponse getProduct(@PathVariable Long id) {
        log.info("Fetching product with id: {}", id);
        Product product = findProduct(id);

        if (product == null) {
            throw new RuntimeException("Product not found with id: " + id);
        }

        int quantity = 0;
        try {
            // Call inventory service using service discovery
            String inventoryUrl = "http://INVENTORY-SERVICE/inventory/" + id;
            log.info("Calling inventory service at: {}", inventoryUrl);

            InventoryResponse inventory = restTemplate.getForObject(
                    inventoryUrl,
                    InventoryResponse.class
            );

            quantity = inventory != null ? inventory.getQuantity() : 0;
            log.info("Received inventory quantity: {}", quantity);
        } catch (Exception e) {
            log.error("Error calling inventory service: {}", e.getMessage());
            // Return product without inventory data
        }

        return new ProductResponse(
                product.getId(),
                product.getName(),
                product.getPrice(),
                quantity);
    }
    @GetMapping("/health")
    public String health() {
        return "Product Service is running!";
    }
    private Product findProduct(Long id) {
        return products.get(id);
    }
}