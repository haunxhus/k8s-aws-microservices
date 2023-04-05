package com.tanerdiler.microservice.product.service;

import com.tanerdiler.microservice.product.event.Event;
import com.tanerdiler.microservice.product.event.ProductEvent;
import com.tanerdiler.microservice.product.model.Product;
import com.tanerdiler.microservice.product.repository.ProductRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.util.concurrent.ListenableFutureCallback;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Slf4j
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private KafkaTemplate<String, Event> kafkaTemplate;

    @Value("${spring.kafka.topic.topic-send-product}")
    private String topicSendProduct;

    private void sendProductEvent(Event event, String topic) {
        log.info("Send to kafka queue to topic : {}, event : {}", topic, event);
        ListenableFuture<SendResult<String, Event>> future = (ListenableFuture<SendResult<String, Event>>) kafkaTemplate.send(topicSendProduct, event);
        future.addCallback(new ListenableFutureCallback<>() {
            @Override
            public void onFailure(Throwable ex) {
                log.error("Unable to send message nft event due to: " + ex.getMessage(), ex);
            }

            @Override
            public void onSuccess(SendResult<String, Event> result) {
                log.info("Send message event successful");
            }
        });
    }

    @Override
    public void sendProductToOrder() {
        Event event = new Event();
        ProductEvent productEvent = new ProductEvent("oto", 15000D, "PREPARE");
        event.getProductEvent().add(productEvent);
        this.sendProductEvent(event, topicSendProduct);
    }

    @Override
    @Cacheable("products")
    public List<Product> getAll() {
        List<Product> list = getProductList();
        System.out.println("Call method");
        return list;
    }

    private List<Product> getProductList() {
        Optional<Collection<Product>> products = productRepository.findAll();
        Collection<Product> result = products.get();
        List<Product> list = result.stream().collect(Collectors.toList());
        return list;
    }

    @Override
    @Cacheable(value = "products", key = "#id")
    public Product findById(Integer id) {
        System.out.println("Call method");
        return productRepository.findById(id);
    }

    @Override
    @CacheEvict("products")
    public void deleteById(Integer id) {
        List<Product> list = this.getProductList();
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).getId() == id) {
                list.remove(i);
            }
        }
    }

    @Override
    @CacheEvict(value = "products", allEntries = true)
    public void deleteAll() {
        System.out.println("Call method");
        List<Product> list = this.getProductList();
        for (int i = 0; i < list.size(); i++) {
            list.remove(i);
        }
    }

    @Override
    @CachePut(value = "products", key = "#id")
    public Product update(Product product, Integer id) {
        Product current = productRepository.findById(product.getId());
        current.setName(product.getName());
        current.setPrice(product.getPrice());
        return current;
    }

}
