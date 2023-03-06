package com.example.minioconnectionjava17.repository;

import io.minio.*;
import io.minio.http.Method;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import org.springframework.web.multipart.MultipartFile;

import java.util.concurrent.TimeUnit;

@Repository
public class MinioRepository implements IORepository{

    @Value("${minio.upload.partSize}")
    private long partSizeUpload;

    @Value("${minio.download.expiryTime}")
    private int expiryTimeObject;

    private MinioClient minioClient;

    MinioRepository(MinioClient minioClient) {
        this.minioClient = minioClient;
    }

    @Override
    public void upload(String bucket, MultipartFile multipartFile) throws Exception {
        minioClient.putObject(PutObjectArgs.builder()
                .bucket(bucket)
                .object("/binhkd-001/" + multipartFile.getOriginalFilename())
                .stream(multipartFile.getInputStream(), multipartFile.getSize(), partSizeUpload)
                .build());
    }

    @Override
    public String getFile(String bucket, String objectName) throws Exception {
        return minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                .bucket(bucket)
                .object(objectName)
                .expiry(expiryTimeObject, TimeUnit.SECONDS)
                .method(Method.GET)
                .build());
    }

    @Override
    public void makeBucket(String bucketName) throws Exception {
        minioClient.makeBucket(MakeBucketArgs.builder().bucket(bucketName).build());
    }

    @Override
    public boolean bucketExist(String bucketName) throws Exception {
        return minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucketName).build());
    }
}
