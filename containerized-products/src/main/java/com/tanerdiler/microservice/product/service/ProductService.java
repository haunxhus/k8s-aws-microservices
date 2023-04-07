package com.tanerdiler.microservice.product.service;

import com.tanerdiler.microservice.product.model.Product;

import java.util.List;

public interface ProductService {

    void sendProductToOrder();

    List<Product> getAll() throws InterruptedException;

    Product findById(Integer id) throws InterruptedException;

    void deleteById(Integer id) throws InterruptedException;

    void deleteAll() throws InterruptedException;

    Product update(Product product, Integer id) throws InterruptedException;
}
