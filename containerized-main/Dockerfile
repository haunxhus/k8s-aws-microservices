FROM openjdk:11
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean
ADD wait-for-services.sh /wait-for-services.sh
ADD wait-for-multi-services.sh /wait-for-multi-services.sh
RUN chmod 755 /wait-for-services.sh
RUN chmod 755 /wait-for-multi-services.sh

COPY containerized-main/target/*.jar containerized-main.jar
EXPOSE 2223
ENTRYPOINT ["java",  "-jar", "containerized-main.jar"]
