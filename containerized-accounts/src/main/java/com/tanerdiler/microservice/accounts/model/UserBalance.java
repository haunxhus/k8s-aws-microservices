package com.tanerdiler.microservice.accounts.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


//@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserBalance {
//    @Id
    private int userId;
    private int price;
}
