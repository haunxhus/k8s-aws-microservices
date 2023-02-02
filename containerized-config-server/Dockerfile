# Maven build container

FROM maven:3.8.6-openjdk-11 AS maven_build
COPY pom.xml /tmp/
COPY src /tmp/src/
WORKDIR /tmp/
RUN mvn package

#Pull base image

FROM openjdk:11
RUN apt update
ARG JAR_FILE=*.jar
COPY --from=maven_build /tmp/target/${JAR_FILE} containerized-config-server.jar
ENTRYPOINT ["java", "-jar", "containerized-config-server.jar"]
EXPOSE 8888
