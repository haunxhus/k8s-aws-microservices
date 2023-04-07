package com.tanerdiler.microservice.order.kafka;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.tanerdiler.microservice.order.event.ProductEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class OrderConsumer {

    Gson gson = new Gson();

    @KafkaListener(topics = "send-product", groupId = "order-group",
            containerFactory = "orderKafkaListenerContainerFactory")
    public void reciveMessage(String event) {
        log.info("=> receiveKafkaMessage {}", event);

        JsonObject obj = gson.fromJson(event, JsonObject.class);
        if (obj == null) {
            return;
        }
        processMessage(obj);
    }

    private void processMessage(JsonObject object) {
        if (object.has("ProductEvent")) {
            JsonElement element = object.get("ProductEvent");
            if (element != null && element.isJsonArray()) {
                for (JsonElement e : element.getAsJsonArray()) {
                    JsonObject o = e.getAsJsonObject();
                    if (o != null) {
                        ProductEvent productEvent = gson.fromJson(o, ProductEvent.class);
                        productEvent.setStatus("DONE");
                        System.out.println(productEvent);
                    }
                }
            }
        }
    }

}
