package com.example.minioconnectionjava17.service;

import com.example.minioconnectionjava17.repository.IORepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class MinioService implements IOService{

    public IORepository ioRepository;

    MinioService(IORepository ioRepository) {
        this.ioRepository = ioRepository;
    }

    @Override
    public void upload(String bucket, MultipartFile multipartFile) throws Exception {
        ioRepository.upload(bucket, multipartFile);
    }

    @Override
    public String getObject(String bucket, String objectName) throws Exception {
        return ioRepository.getFile(bucket, objectName);
    }

    @Override
    public void makeBucket(String bucketName) throws Exception {
        if (bucketExist(bucketName)) {
            throw new Exception("Bucket exist");
        }
        ioRepository.makeBucket(bucketName);
    }

    @Override
    public boolean bucketExist(String bucketName) throws Exception {
        return ioRepository.bucketExist(bucketName);
    }
}
