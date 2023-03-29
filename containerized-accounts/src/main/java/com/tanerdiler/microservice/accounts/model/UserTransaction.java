package com.tanerdiler.microservice.accounts.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

//@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserTransaction {
//    @Id
    private Integer orderId;
    private int userId;
    private int amount;
}
