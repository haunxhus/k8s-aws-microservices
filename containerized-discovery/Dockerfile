#step 3,  Maven build container 
FROM maven:3.8.5-openjdk-11 AS maven_construct

COPY pom.xml /pom.xml

COPY /containerized-discovery/pom.xml /tmp/

COPY /containerized-discovery/src /tmp/src/

COPY wait-for-services.sh /tmp/

WORKDIR /tmp/	

RUN mvn clean package

#step 2, pull base image
FROM openjdk:11
# must specific openjdk version to install netcat
# check sql must started then running my application
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean

ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh

RUN ls -la

#step 1, will run combine from maven and oracle
COPY --from=maven_construct /tmp/target/*.jar containerized-discovery.jar

#step 4, default command, final step: build application
ENTRYPOINT ["/wait-for-services.sh", "zipkin", "9411", "java",  "-jar", "containerized-discovery.jar"]
#ENTRYPOINT ["java",  "-jar", "containerized-discovery.jar"]

#CMD /wait-for-services.sh zipkin 9411
EXPOSE 8761