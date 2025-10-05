# E-commerce API Gateway Demo

This demo demonstrates the API Gateway pattern using Spring Cloud Gateway with an e-commerce microservices architecture. It builds upon the [eureka-demo](../eureka-demo) by adding a unified entry point that provides routing, circuit breaking, and cross-cutting concerns.

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
- Centralized logging and monitoring
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

## Architecture Comparison

### Before Gateway (Direct Service Access)

Problems:
- Multiple endpoints for clients to manage
- Client-side load balancing required
- Duplicated CORS, authentication, logging across services
- Service topology exposed to clients
- Difficult to evolve service structure

```javascript
// Client needs to know all service locations
const services = {
  products: 'http://service1:8081',
  inventory: 'http://service2:8082'
};
```

### After Gateway (Unified Access)

Benefits:
- Single endpoint: `http://gateway:8080`
- Centralized cross-cutting concerns
- Service discovery integration
- Circuit breakers and fallbacks
- Request/response transformation capability

```javascript
// Client only needs gateway location
const API_GATEWAY = 'http://gateway:8080';
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

### Global Request Enhancement

```yaml
default-filters:
  - AddRequestHeader=X-Gateway-Name, ChargeRoute-Gateway
  - AddRequestHeader=X-Request-Timestamp, #{T(java.time.Instant).now().toString()}
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

## Monitoring and Metrics

### Gateway Endpoints

```bash
# Gateway health
curl http://localhost:8080/actuator/health

# Route information
curl http://localhost:8080/actuator/gateway/routes

# Global filters
curl http://localhost:8080/actuator/gateway/globalfilters

# Route filters
curl http://localhost:8080/actuator/gateway/routefilters
```

### Service Discovery

```bash
# Eureka apps
curl http://localhost:8761/eureka/apps

# Service instances
curl http://localhost:8761/eureka/apps/PRODUCT-SERVICE
```

## Customization Examples

### Adding Rate Limiting

Add Redis and configure rate limiting:

```yaml
# Add to docker-compose.yml
redis:
  image: redis:alpine
  ports:
    - "6379:6379"

# Add to gateway routes
filters:
  - name: RequestRateLimiter
    args:
      redis-rate-limiter.replenishRate: 10
      redis-rate-limiter.burstCapacity: 20
```

### Custom Filters

The demo includes a logging filter example:

```java
@Component
public class LoggingGlobalFilter implements GlobalFilter, Ordered {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // Add request ID and log requests
        // See: api-gateway/src/main/java/com/chargeroute/gateway/filter/
    }
}
```

## Troubleshooting

### Gateway Not Starting

```bash
# Check Eureka connectivity
curl http://localhost:8761/actuator/health

# Check Docker networks
docker network ls
docker network inspect api-gateway-demo_chargeroute-network
```

### Services Not Registering

```bash
# Check service logs
docker-compose logs product-service
docker-compose logs eureka-server

# Verify Eureka configuration
curl http://localhost:8761/eureka/apps
```

### Routes Not Working

```bash
# Check configured routes
curl http://localhost:8080/actuator/gateway/routes

# Test service directly
docker-compose exec product-service curl http://localhost:8080/actuator/health

# Check route filters
curl http://localhost:8080/actuator/gateway/routefilters
```

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

## Key Benefits Demonstrated

1. **Simplified Client Integration**: One endpoint instead of multiple
2. **Centralized Cross-Cutting Concerns**: CORS, logging, circuit breaking
3. **Service Discovery Integration**: Automatic routing with Eureka
4. **Resilience**: Circuit breakers prevent cascade failures
5. **Operational Visibility**: Centralized monitoring and metrics
6. **Evolution Support**: Services can change without client updates

## Next Steps

This demo provides the foundation for:

- **Authentication**: Add JWT validation at the gateway
- **Rate Limiting**: Implement Redis-backed request throttling
- **API Versioning**: Support multiple API versions simultaneously  
- **Request Transformation**: Modify requests/responses in transit
- **WebSocket Support**: Enable real-time communication through the gateway
- **Advanced Routing**: Geographic, weighted, or feature-flag based routing

## Learning Resources

- [Spring Cloud Gateway Documentation](https://spring.io/projects/spring-cloud-gateway)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)
- [API Gateway Pattern](https://microservices.io/patterns/apigateway.html)
- [Project Reactor (Reactive Programming)](https://projectreactor.io/)

---

*This demo is part of the microservices learning series. Previous: [eureka-demo](../eureka-demo)*