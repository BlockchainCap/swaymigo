library fungible_token;
use std::{address::Address, hash::*, logging::*, revert::*, storage::*};

storage {
    supply: u64,
    balances: StorageMap<Address,
    u64>, 
}

struct Mint {
    amount: u64,
}

struct Burn {
    amount: u64,
}

struct Transfer {
    from: Address,
    to: Address,
    amount: u64,
}

pub fn mint_tokens(to: Address, mint_amount: u64) {
    storage.supply = storage.supply + mint_amount;
    let curr_balance = storage.balances.get(to);
    storage.balances.insert(to, mint_amount + curr_balance);
    log(Mint {
        amount: mint_amount
    });
}

pub fn burn_tokens(from: Address, burn_amount: u64) {
    let curr_balance = storage.balances.get(from);
    if burn_amount > curr_balance {
        revert(0);
    }
    storage.supply = storage.supply - burn_amount;
    storage.balances.insert(from, curr_balance - burn_amount);
    log(Burn {
        amount: burn_amount
    });
}

pub fn transfer(from: Address, to: Address, amount: u64) {
    if get_balance(from) >= amount {
        let sender_pre_balance = get_balance(from);
        let receiver_pre_balance = get_balance(to);
        storage.balances.insert(from, sender_pre_balance - amount);
        storage.balances.insert(to, receiver_pre_balance + amount);
    } else {
        revert(0);
    }
    log(Transfer {
        from: from, to: to, amount: amount
    });
}

pub fn get_balance(of: Address) -> u64 {
    return storage.balances.get(of);
}

pub fn get_total_supply() -> u64 {
    return storage.supply;
}
