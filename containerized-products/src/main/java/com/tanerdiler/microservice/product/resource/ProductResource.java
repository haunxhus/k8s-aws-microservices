package com.tanerdiler.microservice.product.resource;

import java.util.Collection;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tanerdiler.microservice.product.model.Product;
import com.tanerdiler.microservice.product.repository.ProductRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import javax.ws.rs.PUT;

@Slf4j
@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductResource {

	private final ProductRepository repository;

	@Value("${containerized.app.name}")
	private String myAppName;

	@GetMapping("/app-name")
	public String getContainerizedAppName() {
		log.info("Product info /app-name");
		log.warn("Product warn /app-name");
		log.error("Product error /app-name");
		return myAppName;
	}

	@GetMapping("/{id}")
	public ResponseEntity<Product> get(@PathVariable("id") Integer id) {
		final var product = repository.findById(id);
		log.info("Product {} info detail fetched {}", id, product);
		log.warn("Product {} warn detail fetched {}", id, product);
		log.error("Product {} error detail fetched {}", id, product);
		return ResponseEntity.ok(product);
	}

	@GetMapping()
	public ResponseEntity<Collection<Product>> getAll() {
		final var products = repository.findAll().get();
		log.info("info Executing fetching all products {}", products);
		log.warn("warn Executing fetching all products {}", products);
		log.error("error Executing fetching all products {}", products);
		return ResponseEntity.ok(products);
	}

	@PutMapping("/{productId}")
	public ResponseEntity<Boolean> updateProductInventory(@PathVariable("productId") Integer productId, @RequestParam Double amount) {
		log.info("Update product inventory {}", productId);
		Boolean isUpdateProductInventorySuccess = repository.updateProductInventory(productId, amount);
		return new ResponseEntity<>(isUpdateProductInventorySuccess, HttpStatus.OK);
	}

}
