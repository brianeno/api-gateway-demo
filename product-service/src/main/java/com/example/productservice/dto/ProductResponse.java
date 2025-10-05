package com.example.productservice.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProductResponse {
    private Long id;
    private String name;
    private Double price;
    private Integer availableQuantity;

    public ProductResponse() {
    }

    public ProductResponse(Long id, String name, Double price, Integer availableQuantity) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.availableQuantity = availableQuantity;
    }
}