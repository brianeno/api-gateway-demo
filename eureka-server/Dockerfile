FROM eclipse-temurin:21-jdk
VOLUME /tmp
COPY target/*.jar app.jar
RUN apt-get update && apt-get install -y curl
ENTRYPOINT ["java","-jar","/app.jar"]