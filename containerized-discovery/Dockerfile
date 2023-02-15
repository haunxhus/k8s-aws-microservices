FROM openjdk:11
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean
ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh
COPY containerized-discovery/target/*.jar containerized-discovery.jar
#ENTRYPOINT ["/wait-for-services.sh", "zipkin", "9411", "java",  "-jar", "containerized-discovery.jar"]
ENTRYPOINT ["java",  "-jar", "containerized-discovery.jar"]
EXPOSE 8761
