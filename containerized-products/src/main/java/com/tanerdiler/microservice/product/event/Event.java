package com.tanerdiler.microservice.product.event;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Event {
    @JsonProperty("ProductEvent")
    public List<ProductEvent> productEvent = new ArrayList<>();
}
