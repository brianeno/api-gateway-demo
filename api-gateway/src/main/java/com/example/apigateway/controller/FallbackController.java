package com.example.apigateway.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    private static final Logger logger = LoggerFactory.getLogger(FallbackController.class);

    @GetMapping("/products/**")
    public Mono<ResponseEntity<Map<String, Object>>> productServiceFallback() {
        logger.warn("Product service circuit breaker activated - returning fallback response");

        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of(
                        "status", "error",
                        "message", "Product service is temporarily unavailable. Please try again later.",
                        "service", "product-service",
                        "fallback", true,
                        "timestamp", Instant.now().toString()
                )));
    }

    @RequestMapping(value = "/inventory/**", method = {RequestMethod.GET, RequestMethod.PUT})
    public Mono<ResponseEntity<Map<String, Object>>> inventoryServiceFallback() {
        logger.warn("Inventory service circuit breaker activated - returning fallback response");

        return Mono.just(ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of(
                        "status", "error",
                        "message", "Inventory service is temporarily unavailable",
                        "service", "inventory-service",
                        "fallback", true,
                        "timestamp", Instant.now().toString(),
                        "suggestion", "Product availability data may be cached in the application"
                )));
    }
}