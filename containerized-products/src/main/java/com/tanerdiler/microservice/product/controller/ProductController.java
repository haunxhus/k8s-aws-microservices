package com.tanerdiler.microservice.product.controller;

import com.tanerdiler.microservice.product.model.Product;
import com.tanerdiler.microservice.product.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping ("/send-event")
    public void sendEventProduct() {
        productService.sendProductToOrder();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> findById(@PathVariable("id")Integer id) throws InterruptedException {
        return new ResponseEntity<>(productService.findById(id), HttpStatus.OK);
    }

    @GetMapping("")
    public ResponseEntity<List<Product>> getAll() throws InterruptedException {
        return new ResponseEntity<>(productService.getAll(), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteById(@PathVariable("id")Integer id) throws InterruptedException {
        productService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> update(@RequestBody Product product, @PathVariable("id") Integer id) throws InterruptedException {
        return new ResponseEntity<>(productService.update(product, id),HttpStatus.OK);
    }

    @DeleteMapping("delete-cache")
    public void deleteAll() throws InterruptedException {
        productService.deleteAll();
    }

    @GetMapping("/test")
    public ResponseEntity<String> test(){
        return new ResponseEntity<>("OK", HttpStatus.OK);
    }
}
