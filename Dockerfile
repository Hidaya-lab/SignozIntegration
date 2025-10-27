# ===== Stage 1: Build the application with Maven =====
FROM maven:3.9.6-eclipse-temurin-20-jdk

WORKDIR /app

COPY pom.xml ./
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests


# ===== Stage 2: Run the application with OpenTelemetry =====
FROM eclipse-temurin:20-jdk

WORKDIR /app
COPY /app/target/*.jar app.jar

ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar

ENV OTEL_SERVICE_NAME=hello-java-app
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4318
ENV OTEL_METRICS_EXPORTER=otlp
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_LOGS_EXPORTER=otlp

EXPOSE 9000

ENTRYPOINT ["java", "-javaagent:/app/opentelemetry-javaagent.jar", "-jar", "app.jar"]
