package com.tanerdiler.microservice.order.model;

import com.tanerdiler.microservice.order.event.OrderStatus;
import com.tanerdiler.microservice.order.event.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PurchaseOrder {

    private Integer id;
    private Integer userId;
    private Integer productId;
    private Integer price;
    private OrderStatus orderStatus;
    private PaymentStatus paymentStatus;
}
