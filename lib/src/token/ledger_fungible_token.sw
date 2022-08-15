library ledger_fungible_token;
use std::{hash::*, identity::Identity, logging::*, revert::*, storage::*};

// storage not currently supported in libraries, do it manually
const SUPPLY_BALANCE: b256 = 0x00000000000000000000000000000000000000000000000000000000aaaaaba1;
const BALANCE_SALT: b256 = 0x0000000000000000000000000000000000000000000000000000000000000ba1;

#[storage(read)]fn temp_get_supply() -> u64 {
    get::<u64>(SUPPLY_BALANCE)
}

#[storage(write)]fn temp_set_supply(s: u64) {
    store::<u64>(SUPPLY_BALANCE, s)
}

#[storage(write)]fn temp_balance_insert(key: Identity, val: u64) {
    let slot = sha256((BALANCE_SALT, key));
    store::<u64>(slot, val);
}

#[storage(read)]fn temp_balance_get(key: Identity) -> u64 {
    let slot = sha256((BALANCE_SALT, key));
    get::<u64>(slot)
}

struct Mint {
    amount: u64,
}

struct Burn {
    amount: u64,
}

struct Transfer {
    from: Identity,
    to: Identity,
    amount: u64,
}

#[storage(read, write)]pub fn mint_tokens(to: Identity, mint_amount: u64) {
    // storage.supply = storage.supply + mint_amount;
    temp_set_supply(temp_get_supply() + mint_amount);
    let curr_balance = get_balance(to);
    // storage.balances.insert(to, mint_amount + curr_balance);
    temp_balance_insert(to, mint_amount + curr_balance);
    log(Mint {
        amount: mint_amount
    });
}

#[storage(read, write)]pub fn burn_tokens(from: Identity, burn_amount: u64) {
    let curr_balance = get_balance(from);
    if burn_amount > curr_balance {
        revert(0);
    }
    // storage.supply = storage.supply - burn_amount;
    temp_set_supply(temp_get_supply() - burn_amount);
    // storage.balances.insert(from, curr_balance - burn_amount);
    temp_balance_insert(from, curr_balance - burn_amount);
    log(Burn {
        amount: burn_amount
    });
}

#[storage(read, write)]pub fn f_transfer(from: Identity, to: Identity, amount: u64) {
    if get_balance(from) >= amount {
        let sender_pre_balance = get_balance(from);
        let receiver_pre_balance = get_balance(to);
        // storage.balances.insert(from, sender_pre_balance - amount);
        temp_balance_insert(from, sender_pre_balance - amount);
        // storage.balances.insert(to, receiver_pre_balance + amount);
        temp_balance_insert(to, receiver_pre_balance + amount);
    } else {
        revert(0);
    }
    log(Transfer {
        from: from, to: to, amount: amount
    });
}

#[storage(read)]pub fn get_balance(of: Identity) -> u64 {
    return temp_balance_get(of);
}

#[storage(read)]pub fn get_total_supply() -> u64 {
    return temp_get_supply()
}
