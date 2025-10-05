#!/bin/bash

echo "Building API Gateway Demo..."
echo "========================================"

# Build Eureka Server
echo "Building Eureka Server..."
cd eureka-server
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "Failed to build Eureka Server"
    exit 1
fi
cd ..

# Build Product Service
echo "Building Product Service..."
cd product-service
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "Failed to build Product Service"
    exit 1
fi
cd ..

# Build Inventory Service
echo "Building Inventory Service..."
cd inventory-service
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "Failed to build Inventory Service"
    exit 1
fi
cd ..

# Build API Gateway
echo "Building API Gateway..."
cd api-gateway
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "Failed to build API Gateway"
    exit 1
fi
cd ..

echo "========================================"
echo "Build complete! You can now run:"
echo "  1. docker-compose up"
echo "  OR"
echo "  2. Run each service individually with Maven"
echo ""
echo "Visit http://localhost:8761 for Eureka Dashboard"
echo "Visit http://localhost:8080 for API Gateway"