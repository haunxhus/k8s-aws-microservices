FROM openjdk:11-jdk-slim
MAINTAINER JavaTeamDu5 <JavaTeamDu5@vmodev.com>
ADD containerized-zipkin/target/*.jar containerized-zipkin.jar
ENTRYPOINT ["java", "-jar", "/containerized-zipkin.jar"]
EXPOSE 8761
