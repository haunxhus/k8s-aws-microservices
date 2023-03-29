FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean
ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh
COPY containerized-authorization-server/target/*.jar containerized-authorization-server.jar
EXPOSE 9000
ENTRYPOINT ["java",  "-jar", "containerized-authorization-server.jar"]
