package com.example.minioconnectionjava17.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MinioConnection {

    @Value("${minio.endPoint}")
    private String minioEndPoint;

    @Value("${minio.accessKey}")
    private String minioAccessKey;

    @Value("${minio.secretKey}")
    private String minioSecretKey;

    @Bean
    public MinioClient minioClient() {
        MinioClient minioClient = MinioClient.builder()
                .endpoint(minioEndPoint)
                .credentials(minioAccessKey, minioSecretKey)
                .build();

        return minioClient;
    }
}
