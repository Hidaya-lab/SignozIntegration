# Use Java 20 JDK
FROM eclipse-temurin:20-jdk

# Set working directory
WORKDIR /app

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
