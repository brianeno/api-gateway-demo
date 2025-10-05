#!/bin/bash

# Test script for E-commerce API Gateway Demo
# This script demonstrates the API Gateway routing functionality

GATEWAY_URL="http://localhost:8080"
EUREKA_URL="http://localhost:8761"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}E-commerce API Gateway Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if services are running
echo -e "\n${YELLOW}1. Checking service availability...${NC}"

# Check Eureka
echo -n "Eureka Server: "
if curl -s -f $EUREKA_URL/actuator/health > /dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${RED}✗ Not available${NC}"
    echo "Please start Eureka server first: docker-compose up eureka-server"
    exit 1
fi

# Check Gateway
echo -n "API Gateway: "
if curl -s -f $GATEWAY_URL/actuator/health > /dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${RED}✗ Not available${NC}"
    echo "Please start the API Gateway: docker-compose up api-gateway"
    exit 1
fi

# Test gateway routes
echo -e "\n${YELLOW}2. Testing Gateway Routes...${NC}"

echo -e "\n${BLUE}Testing Product Service Route:${NC}"
echo "GET $GATEWAY_URL/api/products/1"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" $GATEWAY_URL/api/products/1)
http_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Status: $http_code${NC}"
    echo "$body" | jq . 2>/dev/null || echo "$body"
else
    echo -e "${RED}✗ Status: $http_code${NC}"
    echo "$body"
fi

echo -e "\n${BLUE}Testing Inventory Service Route:${NC}"
echo "GET $GATEWAY_URL/api/inventory/1"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" $GATEWAY_URL/api/inventory/1)
http_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Status: $http_code${NC}"
    echo "$body" | jq . 2>/dev/null || echo "$body"
else
    echo -e "${RED}✗ Status: $http_code${NC}"
    echo "$body"
fi

echo -e "\n${BLUE}Testing Inventory Update Route:${NC}"
echo "PUT $GATEWAY_URL/api/inventory/1?quantity=150"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X PUT \
    "$GATEWAY_URL/api/inventory/1?quantity=150")
http_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Status: $http_code${NC}"
    echo "$body" | jq . 2>/dev/null || echo "$body"
else
    echo -e "${RED}✗ Status: $http_code${NC}"
    echo "$body"
fi

echo -e "\n${BLUE}Testing Product Health Check:${NC}"
echo "GET $GATEWAY_URL/api/products/health"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" $GATEWAY_URL/api/products/health)
http_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Status: $http_code${NC}"
    echo "$body"
else
    echo -e "${RED}✗ Status: $http_code${NC}"
    echo "$body"
fi

# Test circuit breaker functionality
echo -e "\n${YELLOW}3. Testing Circuit Breaker...${NC}"
echo "Testing fallback when services are unavailable..."

# Try to access non-existent product to test fallback
echo -e "\n${BLUE}Testing Product Service Fallback:${NC}"
echo "GET $GATEWAY_URL/api/products/999"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" $GATEWAY_URL/api/products/999)
http_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')

echo -e "Status: $http_code"
echo "$body" | jq . 2>/dev/null || echo "$body"

# Test gateway metrics
echo -e "\n${YELLOW}4. Checking Gateway Metrics...${NC}"
echo "GET $GATEWAY_URL/actuator/gateway/routes"
curl -s $GATEWAY_URL/actuator/gateway/routes | jq . 2>/dev/null || curl -s $GATEWAY_URL/actuator/gateway/routes

# Test headers and request enhancement
echo -e "\n${YELLOW}5. Testing Request Enhancement...${NC}"
echo "Checking headers added by gateway filters..."
response=$(curl -s -v $GATEWAY_URL/api/products/1 2>&1)
echo "$response" | grep -E "(X-Gateway-Name|X-Request-Timestamp|X-Request-Id)" || echo "Headers may be added internally"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}API Gateway Test Suite Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}Next Steps:${NC}"
echo "1. View Eureka dashboard: $EUREKA_URL"
echo "2. Check Gateway routes: $GATEWAY_URL/actuator/gateway/routes"
echo "3. Monitor Gateway health: $GATEWAY_URL/actuator/health"
echo "4. Scale services: docker-compose up --scale product-service=2 --scale inventory-service=2"