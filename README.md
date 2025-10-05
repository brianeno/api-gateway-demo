# API Gateway Demo

This demo demonstrates the API Gateway pattern using Spring Cloud Gateway with an e-commerce microservices architecture. It builds upon the [eureka-demo](../eureka-demo) by adding a unified entry point that provides routing, circuit breaking, and cross-cutting concerns.

This is from my medium article **API Gateway with Spring Cloud**

This article and others from me can be found at https://medium.com/@brianenochson

## Architecture Overview

```
Client Applications
        ↓
   API Gateway (8080)
        ↓
Service Discovery (Eureka 8761)
        ↓
Backend Microservices
├── Product Service (dynamic port)
└── Inventory Service (dynamic port)
```

## What's Demonstrated

### ✅ API Gateway Features
- **Single Entry Point**: All services accessible through `http://localhost:8080`
- **Dynamic Routing**: Routes automatically resolve through Eureka service discovery
- **Circuit Breakers**: Graceful degradation when services are unavailable
- **Request Enhancement**: Automatic headers for tracing and monitoring
- **CORS Support**: Configured for web and mobile applications
- **Fallback Responses**: Meaningful error messages when services fail

### ✅ Routing Examples
- `GET /api/products/*` → Product Service
- `GET /api/inventory/*` → Inventory Service
- `PUT /api/inventory/*` → Inventory Service
- `GET /actuator/*` → Gateway management endpoints

### ✅ Integration Benefits
- Load balancing across multiple service instances
- Simplified client integration
- Service abstraction and versioning support

## Prerequisites

- Java 21+
- Maven 3.9+
- Docker & Docker Compose
- curl (for testing)
- jq (optional, for JSON formatting)

## Quick Start

### 1. Start All Services

```bash
# Build and start all services in correct order
docker-compose up --build

# Or start in background
docker-compose up --build -d
```

This will start:
- Eureka Server (port 8761)
- Product Service (2 instances, dynamic ports)
- Inventory Service (2 instances, dynamic ports)
- API Gateway (port 8080)

### 2. Verify Services

Check that all services are registered:

```bash
# View Eureka dashboard
open http://localhost:8761

# Check gateway health
curl http://localhost:8080/actuator/health

# View available routes
curl http://localhost:8080/actuator/gateway/routes
```

### 3. Test the Gateway

Run the automated test suite:

```bash
./test-gateway.sh
```

Or test manually:

```bash
# Test product service through gateway
curl http://localhost:8080/api/products/1

# Test inventory service through gateway
curl http://localhost:8080/api/inventory/1

# Test inventory update through gateway
curl -X PUT http://localhost:8080/api/inventory/1?quantity=150

# Test product health check through gateway
curl http://localhost:8080/api/products/health
```

## Gateway Configuration Highlights

### Dynamic Routing with Service Discovery

```yaml
spring:
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true
          lower-case-service-id: true
```

### Circuit Breaker Integration

```yaml
routes:
  - id: product-service
    uri: lb://product-service
    predicates:
      - Path=/api/products/**
    filters:
      - name: CircuitBreaker
        args:
          name: productService
          fallbackUri: forward:/fallback/products
```

### Default Filters (Global Request Enhancement)

Default filters are applied to all routes automatically, providing consistent cross-cutting functionality:

```yaml
default-filters:
  - name: DedupeResponseHeader
    args:
      name: Access-Control-Allow-Origin
      strategy: RETAIN_FIRST
  - name: AddRequestHeader
    args:
      name: X-Gateway-Name
      value: API-Gateway
```

**What these filters do:**
- `DedupeResponseHeader`: Removes duplicate CORS headers that can occur when both the gateway and backend services set them
- `AddRequestHeader`: Adds gateway identification to every request for debugging and monitoring

**Additional commonly used default filters:**
```yaml
# Example: Add timestamp to all requests
- name: AddRequestHeader
  args:
    name: X-Request-Timestamp
    value: "#{T(java.time.Instant).now().toString()}"

# Example: Remove sensitive headers from responses
- name: RemoveResponseHeader
  args:
    name: Server

# Example: Add response headers for security
- name: AddResponseHeader
  args:
    name: X-Frame-Options
    value: DENY
```

## Testing Circuit Breakers

Stop a service to test fallback behavior:

```bash
# Stop product service
docker-compose stop product-service

# Test fallback response
curl http://localhost:8080/api/products/1
# Returns: {"status":"error","message":"Product service is temporarily unavailable",...}

# Restart service
docker-compose start product-service
```

## Scaling Services

Test load balancing with multiple instances:

```bash
# Scale product service to 3 instances
docker-compose up --scale product-service=3 -d

# Verify in Eureka dashboard
open http://localhost:8761

# Test load balancing
for i in {1..3}; do
  curl http://localhost:8080/api/products/$i
done
```

## Service Discovery

```bash
# Eureka apps
curl http://localhost:8761/eureka/apps

# Service instances
curl http://localhost:8761/eureka/apps/PRODUCT-SERVICE
```

## Troubleshooting

## Project Structure

```
api-gateway-demo/
├── api-gateway/              # Spring Cloud Gateway service
│   ├── src/main/java/
│   │   └── com/chargeroute/gateway/
│   │       ├── ApiGatewayApplication.java
│   │       ├── controller/
│   │       │   └── FallbackController.java
│   │       └── filter/
│   │           └── LoggingGlobalFilter.java
│   ├── src/main/resources/
│   │   └── application.yml
│   ├── Dockerfile
│   └── pom.xml
├── eureka-server/            # Service discovery (from eureka-demo)
├── product-service/          # Product catalog management (from eureka-demo)
├── inventory-service/        # Inventory tracking (from eureka-demo)
├── docker-compose.yml       # Multi-service orchestration
├── test-gateway.sh         # Automated testing script
└── README.md              # This file
```

---

*This demo is part of the microservices learning series as preview to my upcoming book Architecting Microservices with Spring Boot and Spring Cloud with Apress. Previous: [eureka-demo](https://github.com/brianeno//eureka-demo)*