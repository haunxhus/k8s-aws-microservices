package com.tanerdiler.microservice.order.resource;

import com.tanerdiler.microservice.order.model.Order;
import com.tanerdiler.microservice.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;

@Slf4j
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderResource {
    private final OrderRepository repository;

    @Value("${containerized.app.name}")
    private String myAppName;

    @GetMapping("/app-name")
    public String getContainerizedAppName() {
        return myAppName;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> get(@PathVariable("id") Integer id) {
        final var order = repository.findById(id).get();
        log.info("Order {} detail fetched {}", id, order);
        return ResponseEntity.ok(order);
    }

    @GetMapping()
    public ResponseEntity<Collection<Order>> getAll() {
        final var orders = repository.findAll().get();
        log.info("Executing fetching all orders {}", orders);
        return ResponseEntity.ok(orders);
    }

    @PostMapping()
    public ResponseEntity<Order> create(@RequestBody Order order) {
        log.info("Creating new order {}", order);
        final var orders = repository.save(order);
        return new ResponseEntity<>(order, HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOrderById(@PathVariable("id") Integer id) {
        log.info("Delete order with id {}", id);
        repository.deleteOrder(id);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
