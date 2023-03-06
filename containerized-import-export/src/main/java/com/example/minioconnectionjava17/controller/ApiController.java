package com.example.minioconnectionjava17.controller;

import com.example.minioconnectionjava17.service.IOService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
public class ApiController extends AbstractController {
    private IOService ioService;

    ApiController(IOService ioService) {
        this.ioService = ioService;
    }

    @RequestMapping(value = "/makeBucket", method = RequestMethod.POST)
    public ResponseEntity makeBucket(@RequestParam("bucketName") String bucketName) throws Exception {
        ioService.makeBucket(bucketName);
        return ResponseEntity.ok("OK");
    }

    @RequestMapping(value = "/bucketExist", method = RequestMethod.GET)
    public ResponseEntity bucketExist(@RequestParam("bucketName") String bucketName) throws Exception {
        ioService.bucketExist(bucketName);
        return ResponseEntity.ok(ioService.bucketExist(bucketName));
    }

    @RequestMapping(value = "/upload", method = RequestMethod.POST)
    public ResponseEntity uploadFile(@RequestParam("bucketName") String bucketName, @RequestParam("file") MultipartFile multipartFile) throws Exception {
        ioService.upload(bucketName, multipartFile);
        return ResponseEntity.ok("Uploaded");
    }

    @RequestMapping(value = "/download", method = RequestMethod.GET)
    public ResponseEntity uploadFile(@RequestParam("bucketName") String bucketName, @RequestParam("fileName") String fileName) throws Exception {
        return ResponseEntity.ok(ioService.getObject(bucketName, fileName));
    }
}
