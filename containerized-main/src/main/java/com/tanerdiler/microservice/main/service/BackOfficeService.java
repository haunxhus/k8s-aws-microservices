package com.tanerdiler.microservice.main.service;

import com.tanerdiler.microservice.main.dto.OrderDTO;
import com.tanerdiler.microservice.main.dto.OrderRequest;

public interface BackOfficeService {

    public OrderDTO createOrder(OrderRequest request);
}
