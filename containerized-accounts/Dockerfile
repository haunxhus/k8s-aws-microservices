FROM openjdk:11
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean
ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh
COPY containerized-accounts/target/*.jar containerized-accounts.jar
EXPOSE 2222
ENTRYPOINT ["java",  "-jar", "containerized-accounts.jar"]
