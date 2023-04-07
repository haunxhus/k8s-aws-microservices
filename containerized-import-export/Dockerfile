FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu
RUN apt-get -q update && apt-get -qy install netcat && apt-get clean
ADD wait-for-services.sh /wait-for-services.sh
RUN chmod 755 /wait-for-services.sh

EXPOSE 8080

ENV MINIO_ENDPOINT $MINIO_ENDPOINT
ENV MINIO_ACCESS_KEY $MINIO_ACCESS_KEY
ENV MINIO_SECRET_KEY $MINIO_SECRET_KEY
ENV MINIO_UPLOAD_PART_SIZE $MINIO_UPLOAD_PART_SIZE
ENV MINIO_DOWNLOAD_EXPIRY_TIME $MINIO_DOWNLOAD_EXPIRY_TIME
ENV APPLICATION_MODE_DEBUG $APPLICATION_MODE_DEBUG

COPY containerized-import-export/target/*.jar containerized-import-export.jar

ENTRYPOINT ["java","-jar","containerized-import-export.jar"]
