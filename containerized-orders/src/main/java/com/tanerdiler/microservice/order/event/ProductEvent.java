package com.tanerdiler.microservice.order.event;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ProductEvent {
    private String name;
    private Double price;
    private String status;
}