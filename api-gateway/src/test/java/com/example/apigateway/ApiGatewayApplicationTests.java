package com.example.apigateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = {
    "eureka.client.enabled=false",
    "eureka.client.register-with-eureka=false", 
    "eureka.client.fetch-registry=false",
    "spring.cloud.gateway.discovery.locator.enabled=false",
    "spring.cloud.service-registry.auto-registration.enabled=false"
})
class ApiGatewayApplicationTests {

    @Test
    void contextLoads() {
        // Test that the Spring context loads successfully
        // This test verifies that all components can be wired together
    }
}