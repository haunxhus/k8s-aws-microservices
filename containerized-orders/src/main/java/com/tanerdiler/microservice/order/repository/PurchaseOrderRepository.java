package com.tanerdiler.microservice.order.repository;

import com.tanerdiler.microservice.order.event.OrderStatus;
import com.tanerdiler.microservice.order.event.PaymentStatus;
import com.tanerdiler.microservice.order.model.PurchaseOrder;
import org.springframework.stereotype.Repository;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public class PurchaseOrderRepository {

    private final static Map<Integer, PurchaseOrder> purchaseOrders = new HashMap<>();

    static {
        purchaseOrders.put(1, new PurchaseOrder(1, 1, 123, 5000, OrderStatus.ORDER_COMPLETED, PaymentStatus.PAYMENT_COMPLETED));
    }

    public Optional<PurchaseOrder> findById(Integer id)
    {
        return Optional.ofNullable(purchaseOrders.get(id));
    }

    public List<PurchaseOrder> findAll() {
        return new ArrayList<>(purchaseOrders.values());
    }

    public PurchaseOrder save(PurchaseOrder purchaseOrder)
    {
        int maxId = CollectionUtils.isEmpty(purchaseOrders) ? 1 : purchaseOrders.keySet().stream().max(Integer::compareTo).get() + 1;
        purchaseOrder.setId(maxId);
        purchaseOrders.put(maxId, purchaseOrder);
        return purchaseOrder;
    }

    public void delete(PurchaseOrder PurchaseOrder)
    {
        purchaseOrders.remove(PurchaseOrder);
    }
}
