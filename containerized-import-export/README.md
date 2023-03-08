# MinIO Connection
## Setup and Run
### 1. Môi trường
- Java 17
- Maven
- Docker

### 2. Setup and Run
- Config properties hoặc biến môi trường theo file **src/main/resources** 
- Run
```
mvn clean install

mvn spring-boot:run
```

### 3. Build and Run
- Build
```
mvn clean íntall -DskipTests

mvn package

docker build -t minio-connection .
```

- Run
```
docker run -d \
   -p 8080:8080 \
   --name minio-connection \
   --net=bridge \
   -e "MINIO_ENDPOINT=MINIO_ENDPOINT" \
   -e "MINIO_ACCESS_KEY=MINIO_ACCESS_KEY" \
   -e "MINIO_SECRET_KEY=MINIO_SECRET_KEY" \
   -e "MINIO_UPLOAD_PART_SIZE=MINIO_UPLOAD_PART_SIZE" \
   -e "MINIO_DOWNLOAD_EXPIRY_TIME=MINIO_DOWNLOAD_EXPIRY_TIME" \
   -e "APPLICATION.MODE.DEBUG=false" \
   minio-connection
```



