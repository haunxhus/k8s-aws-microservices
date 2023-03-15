package com.tanerdiler.microservice.product.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product implements Serializable {

	private static final long serialVersionUID = -7309602698016517697L;
	private Integer id;
	private String name;
	private Double price;
	private Double amount;
}
