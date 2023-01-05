FROM openjdk:11-jdk-slim
MAINTAINER JavaTeamDu5 <JavaTeamDu5@vmodev.com>
ADD target/containerized-zipkin.jar containerized-zipkin.jar
ENTRYPOINT ["java", "-jar", "/containerized-zipkin.jar"]
EXPOSE 8761
