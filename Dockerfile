# ===== Stage 1: Build the application with Maven =====
FROM maven:3.9.6-eclipse-temurin-21-jdk AS build

# Set working directory
WORKDIR /app

# Copy only pom.xml first (for dependency caching)
COPY pom.xml ./

# Download dependencies (cache layer)
RUN mvn dependency:go-offline -B

# Copy project source
COPY src ./src

# Build the application (skip tests for speed)
RUN mvn clean package -DskipTests


# ===== Stage 2: Run the application with OpenTelemetry =====
FROM eclipse-temurin:21-jdk

# Set working directory
WORKDIR /app

# Copy the built JAR from the previous stage
COPY --from=build /app/target/*.jar app.jar

# Download OpenTelemetry Java agent
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar

# Environment variables for OpenTelemetry
ENV OTEL_SERVICE_NAME=hello-java-app
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4318
ENV OTEL_METRICS_EXPORTER=otlp
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_LOGS_EXPORTER=otlp

# Expose your app port (change if needed)
EXPOSE 9000

# Run the Java app with the OpenTelemetry agent
ENTRYPOINT ["java", "-javaagent:/app/opentelemetry-javaagent.jar", "-jar", "app.jar"]
