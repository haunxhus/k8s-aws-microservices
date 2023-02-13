#step 3,  Maven build container 
FROM maven:3.8.5-openjdk-11 AS maven_construct
MAINTAINER JavaTeamDu5 <JavaTeamDu5@vmodev.com>
COPY /zipkin-server/pom.xml /tmp/
COPY /zipkin-server/pom_zipkin_parent.xml /tmp/

COPY /zipkin-server/src /tmp/src/

WORKDIR /tmp/	

RUN mvn clean package -DskipTests

#step 2, pull base image
FROM openjdk:11
# must specific openjdk version to install netcat
# check sql must started then running my application
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean

ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh

#step 1, will run combine from maven and oracle
COPY --from=maven_construct /tmp/target/*exec.jar zipkin-server.jar

EXPOSE 9411
#step 5, default command, final step: build application
#ENTRYPOINT ["/wait-for-services.sh", "logstash", "5000", "java",  "-jar", "zipkin-server.jar"]
ENTRYPOINT ["java",  "-jar", "zipkin-server.jar"]