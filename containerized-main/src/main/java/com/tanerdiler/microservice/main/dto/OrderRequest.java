package com.tanerdiler.microservice.main.dto;

import lombok.Data;

@Data
public class OrderRequest {
    private Integer id;
    private Integer productId;
    private Integer accountId;
    private Integer count;
    private Double price;
    private Double discountedPrice;
}
