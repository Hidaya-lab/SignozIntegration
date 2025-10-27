FROM maven:3.9.6-eclipse-temurin-20-jdk AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests
#FROM eclipse-temurin:21-jre-jammy
#WORKDIR /app
#COPY --from=build /app/target/*.jar app.jar
#EXPOSE 9000
#ENTRYPOINT ["java", "-jar", "app.jar"]

# Use Java 20 JDK
FROM=build eclipse-temurin:20-jdk

# Set working directory
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
# Copy your Java source files into container
COPY HelloDocker.java /app/

# Download OpenTelemetry Java agent
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar

# Compile Java source inside container
RUN javac HelloDocker.java

# Set environment variables for OpenTelemetry
ENV OTEL_SERVICE_NAME=hello-java-app
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://host.docker.internal:4318
ENV OTEL_METRICS_EXPORTER=otlp
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_LOGS_EXPORTER=otlp

# Run the Java app with the OpenTelemetry agent
CMD ["java", "-javaagent:/app/opentelemetry-javaagent.jar", "HelloDocker"]
