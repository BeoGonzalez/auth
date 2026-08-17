# ==========================================
# Etapa 1: Build (Construcción)
# ==========================================
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copiamos primero el pom.xml y descargamos dependencias.
# Un senior hace esto para aprovechar el caché de capas de Docker. 
# Si el pom.xml no cambia, Docker no volverá a descargar todo de internet.
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiamos el código fuente y empaquetamos el microservicio
COPY src ./src
RUN mvn clean package -DskipTests

# ==========================================
# Etapa 2: Runtime (Ejecución)
# ==========================================
# Usamos el JRE (no el JDK) en su versión Alpine (súper ligera y segura)
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Creamos un usuario no-root por seguridad (buena práctica en contenedores)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copiamos SOLO el .jar generado desde la etapa 'builder'
COPY --from=builder /app/target/*.jar app.jar

# Exponemos el puerto de nuestro Identity Provider
EXPOSE 8080

# Comando inmutable para arrancar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]