FROM maven:3.9-eclipse-temurin-21-alpine AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q package -DskipTests

FROM eclipse-temurin:21-jre

WORKDIR /app
COPY --from=build /app/target/app.jar ./app.jar

# Small heap and minimal JIT/GC for faster JVM startup in a short-lived demo container.
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -Xms32m -Xmx128m -XX:TieredStopAtLevel=1 -XX:+UseSerialGC"

CMD ["java", "-jar", "app.jar"]
