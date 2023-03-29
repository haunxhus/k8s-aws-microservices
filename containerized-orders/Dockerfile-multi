#step 3,  Maven build container 
FROM maven:3.8.5-openjdk-11 AS maven_construct
MAINTAINER JavaTeamDu5 <JavaTeamDu5@vmodev.com>
COPY pom.xml /pom.xml

COPY /containerized-orders/pom.xml /tmp/

COPY /containerized-orders/src /tmp/src/

WORKDIR /tmp/	

RUN mvn clean package

#step 2, pull base image
FROM openjdk:11

# must specific openjdk version to install netcat
# check sql must started then running my application
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean

ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh

#step 1, will run combine from maven and oracle
COPY --from=maven_construct /tmp/target/*.jar containerized-orders.jar

EXPOSE 2226

#step 4, default command, final step: build application
ENTRYPOINT ["java",  "-jar", "containerized-orders.jar"]

