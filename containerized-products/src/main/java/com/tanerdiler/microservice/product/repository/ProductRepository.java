package com.tanerdiler.microservice.product.repository;

import com.tanerdiler.microservice.product.model.Product;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Repository
public class ProductRepository {

    private final static Map<Integer, Product> products = new HashMap<>();

    static {
        products.put(1, new Product(1, "5 saatlik şarj aleti", 100D, 10D));
        products.put(2, new Product(2, "traş makinası", 5D, 20D));
        products.put(3, new Product(3, "klavye", 200D, 30D));
        products.put(4, new Product(4, "sırt çantası", 50D, 40D));
    }

    public Product findById(Integer id) {
        Optional<Product> optionalProduct = Optional.ofNullable(products.get(id));
        if (optionalProduct.isPresent()) {
            return optionalProduct.get();
        }
        return null;
    }

    public Optional<Collection<Product>> findAll() {
        return Optional.ofNullable(products.values());
    }

    public Boolean updateProductInventory(Integer id, Double amount) {
        Product product = findById(id);
        if (product != null && product.getAmount() > amount) {
            product.setAmount(product.getAmount() - amount);
            products.put(id, product);
        } else {
            return false;
        }
        return true;
    }

}
