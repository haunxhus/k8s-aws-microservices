package com.example.minioconnectionjava17.service;

import org.springframework.web.multipart.MultipartFile;

public interface IOService {
    void upload(String bucket, MultipartFile file) throws Exception;

    String getObject(String bucket, String objectName) throws Exception;

    void makeBucket(String bucketName) throws Exception;

    boolean bucketExist(String bucketName) throws Exception;
}
