package com.tanerdiler.microservice.main.serviceImpl;

import com.tanerdiler.microservice.main.dto.OrderDTO;
import com.tanerdiler.microservice.main.dto.OrderRequest;
import com.tanerdiler.microservice.main.exception.HandleResourceFailException;
import com.tanerdiler.microservice.main.exception.ResourceNotFoundException;
import com.tanerdiler.microservice.main.model.Account;
import com.tanerdiler.microservice.main.model.Order;
import com.tanerdiler.microservice.main.model.Product;
import com.tanerdiler.microservice.main.repository.AccountServiceClient;
import com.tanerdiler.microservice.main.repository.OrderServiceClient;
import com.tanerdiler.microservice.main.repository.ProductServiceClient;
import com.tanerdiler.microservice.main.resource.BackofficeController;
import com.tanerdiler.microservice.main.service.BackOfficeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class BackOfficeServiceImpl implements BackOfficeService {

    private static final Logger logger = LogManager.getLogger(BackofficeController.class);

    private final ProductServiceClient productService;

    private final OrderServiceClient orderService;

    private final AccountServiceClient accountService;

    @Override
    public OrderDTO createOrder(OrderRequest request) {
        log.info("Fetching account...");
        Account account = accountService.findById(request.getAccountId());
        if (account == null) {
            throw new ResourceNotFoundException("Account not found with id " + request.getAccountId());
        }

        log.info("Fetching product...");
        Product product = productService.findById(request.getProductId());
        if (product == null) {
            throw new ResourceNotFoundException("Product not found with id " + request.getProductId());
        }

        log.info("Create new order...", mapRequestToEntity(request));
        Order order = orderService.createOrder(mapRequestToEntity(request));
        if (order == null) {
            throw new HandleResourceFailException("Create order fail ");
        }
        log.info("Create order done...");

        log.info("Update product inventory...");
        Boolean isUpdateProductInventorySuccess = productService.updateProductInventory(request.getProductId(), request.getCount().doubleValue());
        if (!isUpdateProductInventorySuccess) {
            orderService.deleteOrderById(order.getId());
            throw new HandleResourceFailException("Update product inventory fail ");
        }
        log.info("Update product inventory success...");
        return mapOrderEntityToDto(order, account.getFullname(), product.getName());
    }

    private OrderDTO mapOrderEntityToDto(Order order, String accountFullName, String productName) {
        OrderDTO orderDTO = new OrderDTO(order.getId(),
                order.getCount(), order.getPrice(),
                order.getDiscountedPrice(), accountFullName, productName);
        return orderDTO;
    }

    private Order mapRequestToEntity(OrderRequest request) {
        Order order = new Order();
        order.setId(request.getId());
        order.setPrice(request.getPrice());
        order.setCount(request.getCount());
        order.setAccountId(request.getAccountId());
        order.setDiscountedPrice(request.getDiscountedPrice());
        order.setProductId(request.getProductId());
        return order;
    }
}
