FROM openjdk:11
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean
ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh
COPY containerized-products/target/*.jar containerized-products.jar
EXPOSE 2227
ENTRYPOINT ["java",  "-jar", "containerized-products.jar"]
