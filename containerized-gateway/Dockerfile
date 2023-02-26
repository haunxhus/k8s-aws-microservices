#step 3,  Maven build container 
FROM maven:3.8.5-openjdk-11 AS maven_construct
MAINTAINER JavaTeamDu5 <JavaTeamDu5@vmodev.com>

COPY pom.xml /pom.xml

COPY /containerized-gateway/pom.xml /tmp/

COPY /containerized-gateway/src /tmp/src/

WORKDIR /tmp/	

RUN mvn clean package

#step 2, pull base image
FROM openjdk:11
# must specific openjdk version to install netcat
# check sql must started then running my application
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean

ADD wait-for-multi-services.sh /wait-for-multi-services.sh
RUN chmod 755 /wait-for-multi-services.sh

#step 1, will run combine from maven and oracle
COPY --from=maven_construct /tmp/target/*.jar containerized-gateway.jar

EXPOSE 8762
#step 5, default command, final step: build application
#ENTRYPOINT ["/wait-for-multi-services.sh", "zipkin", "9411", "java",  "-jar", "containerized-gateway.jar"]
ENTRYPOINT ["java",  "-jar", "containerized-gateway.jar"]