FROM openjdk:17
COPY containerized-authorization-server/target/*.jar containerized-authorization-server.jar
EXPOSE 9000
ENTRYPOINT ["java",  "-jar", "containerized-authorization-server.jar"]