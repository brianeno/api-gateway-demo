package com.example.productservice.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InventoryResponse {
    private Long productId;
    private Integer quantity;

    public InventoryResponse() {
    }

    public InventoryResponse(Long productId, Integer quantity) {
        this.productId = productId;
        this.quantity = quantity;
    }
}