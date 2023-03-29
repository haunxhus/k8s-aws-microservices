package com.example.minioconnectionjava17.repository;

import org.springframework.web.multipart.MultipartFile;

public interface IORepository {
    void upload(String bucket, MultipartFile file) throws Exception;

    String getFile(String bucket, String objectName) throws Exception;

    void makeBucket(String bucketName) throws Exception;

    boolean bucketExist(String bucketName) throws Exception;
}
