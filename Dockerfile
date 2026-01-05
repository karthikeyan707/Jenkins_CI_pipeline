FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY sampleapp/target/demo-1.0-SNAPSHOT.jar app.jar

EXPOSE 8080

CMD ["java","-jar","app.jar"]