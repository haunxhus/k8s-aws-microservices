package com.tanerdiler.microservice.accounts.resource;

import com.tanerdiler.microservice.accounts.model.UserBalance;
import com.tanerdiler.microservice.accounts.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/balances")
@RequiredArgsConstructor
public class UserBalanceResource {

    @Autowired
    private PaymentService paymentService;

    @GetMapping
    public List<UserBalance> getBalances(){
        return paymentService.getAllBalances();
    }
}
