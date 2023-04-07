package com.tanerdiler.microservice.main.repository;

import com.tanerdiler.microservice.main.model.Product;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Component
@FeignClient("containerized-products")
public interface ProductServiceClient {
    @GetMapping(value = "/product/api/v1/products/{productId}")
    Product findById(@PathVariable("productId") Integer orderId);

    @GetMapping(value = "/product/api/v1/products")
    List<Product> findAll();

    @PutMapping(value = "/product/api/v1/products/{productId}")
    Boolean updateProductInventory(@PathVariable("productId") Integer productId, @RequestParam Double amount);

    @PutMapping(value = "/product/api/v1/products/{productId}")
    void rollbackProductUpdate(@PathVariable("productId") Integer productId, @RequestParam Double amount);
}
