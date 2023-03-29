package com.tanerdiler.microservice.accounts.service;

import com.tanerdiler.microservice.accounts.dto.OrderRequestDto;
import com.tanerdiler.microservice.accounts.dto.PaymentRequestDto;
import com.tanerdiler.microservice.accounts.event.OrderEvent;
import com.tanerdiler.microservice.accounts.event.PaymentEvent;
import com.tanerdiler.microservice.accounts.event.PaymentStatus;
import com.tanerdiler.microservice.accounts.model.UserBalance;
import com.tanerdiler.microservice.accounts.model.UserTransaction;
import com.tanerdiler.microservice.accounts.repository.UserBalanceRepository;
import com.tanerdiler.microservice.accounts.repository.UserTransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PaymentService {

    @Autowired
    private UserBalanceRepository userBalanceRepository;
    @Autowired
    private UserTransactionRepository userTransactionRepository;

//    @PostConstruct
//    public void initUserBalanceInDB() {
//        userBalanceRepository.saveAll(Stream.of(new UserBalance(101, 5000),
//                new UserBalance(102, 3000),
//                new UserBalance(103, 4200),
//                new UserBalance(104, 20000),
//                new UserBalance(105, 999)).collect(Collectors.toList()));
//    }

    /**
     * // get the user id
     * // check the balance availability
     * // if balance sufficient -> Payment completed and deduct amount from DB
     * // if payment not sufficient -> cancel order event and update the amount in DB
     **/
//    @Transactional
    public PaymentEvent newOrderEvent(OrderEvent orderEvent) {
        OrderRequestDto orderRequestDto = orderEvent.getOrderRequestDto();

        PaymentRequestDto paymentRequestDto = new PaymentRequestDto(orderRequestDto.getOrderId(),
                orderRequestDto.getUserId(), orderRequestDto.getAmount());

        return userBalanceRepository.findById(orderRequestDto.getUserId())
                .filter(ub -> ub.getPrice() > orderRequestDto.getAmount())
                .map(ub -> {
                    ub.setPrice(ub.getPrice() - orderRequestDto.getAmount());
                    userTransactionRepository.save(new UserTransaction(orderRequestDto.getOrderId(), orderRequestDto.getUserId(), orderRequestDto.getAmount()));
                    return new PaymentEvent(paymentRequestDto, PaymentStatus.PAYMENT_COMPLETED);
                }).orElse(new PaymentEvent(paymentRequestDto, PaymentStatus.PAYMENT_FAILED));

    }

//    @Transactional
    public void cancelOrderEvent(OrderEvent orderEvent) {

        userTransactionRepository.findById(orderEvent.getOrderRequestDto().getOrderId())
                .ifPresent(ut->{
                    userTransactionRepository.delete(ut);
                    userTransactionRepository.findById(ut.getUserId())
                            .ifPresent(ub->ub.setAmount(ub.getAmount()+ut.getAmount()));
                });
    }

    public List<UserBalance> getAllBalances(){
        return userBalanceRepository.findAll();
    }
}
