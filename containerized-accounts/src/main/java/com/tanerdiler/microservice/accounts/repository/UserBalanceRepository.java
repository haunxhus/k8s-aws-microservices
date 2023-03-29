package com.tanerdiler.microservice.accounts.repository;

import com.tanerdiler.microservice.accounts.model.UserBalance;
import org.springframework.stereotype.Repository;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public class UserBalanceRepository {

    private final static Map<Integer, UserBalance> userBalances = new HashMap<>();

    static {
        userBalances.put(1, new UserBalance(1, 100000000));
        userBalances.put(2, new UserBalance(2, 200000000));
        userBalances.put(3, new UserBalance(3, 300000000));
        userBalances.put(4, new UserBalance(4, 400000000));
    }

    public Optional<UserBalance> findById(Integer id)
    {
        return Optional.ofNullable(userBalances.get(id));
    }

    public List<UserBalance> findAll() {
        return new ArrayList<>(userBalances.values());
    }

    public UserBalance save(UserBalance userBalance)
    {
        int maxId = CollectionUtils.isEmpty(userBalances) ? 1 : userBalances.keySet().stream().max(Integer::compareTo).get() + 1;
        userBalances.put(maxId, userBalance);
        return  userBalance;
    }

    public void delete(UserBalance userBalance)
    {
        userBalances.remove(userBalance);
    }
}
