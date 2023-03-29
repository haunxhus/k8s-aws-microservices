package com.tanerdiler.microservice.accounts.repository;

import com.tanerdiler.microservice.accounts.model.UserTransaction;
import org.springframework.stereotype.Repository;
import org.springframework.util.CollectionUtils;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Repository
public class UserTransactionRepository {
    private final static Map<Integer, UserTransaction> userTransactions = new HashMap<>();

    static {
        userTransactions.put(1, new UserTransaction(1, 1, 1000000));
        userTransactions.put(2, new UserTransaction(2, 2, 2000000));
        userTransactions.put(3, new UserTransaction(3, 3, 3000000));
        userTransactions.put(4, new UserTransaction(4, 4, 4000000));
    }

    public Optional<UserTransaction> findById(Integer id)
    {
        return Optional.ofNullable(userTransactions.get(id));
    }

    public Optional<Collection<UserTransaction>> findAll() {
        return Optional.ofNullable(userTransactions.values());
    }

    public UserTransaction save(UserTransaction userTransaction)
    {
        int maxId = CollectionUtils.isEmpty(userTransactions) ? 1 : userTransactions.keySet().stream().max(Integer::compareTo).get() + 1;
        userTransactions.put(maxId, userTransaction);
        return userTransaction;
    }

    public void delete(UserTransaction userTransaction)
    {
        userTransactions.remove(userTransaction);
    }
}
