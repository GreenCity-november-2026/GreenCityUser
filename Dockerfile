FROM eclipse-temurin:21-jre
WORKDIR /app
COPY core/target/app.jar app.jar
EXPOSE 8060
ENTRYPOINT ["java", "-jar", "app.jar"]
