library fungible_token;
use std::{address::Address, hash::*, logging::*, revert::*, storage::*};

// storage not currently supported in libraries, do it manually 
storage {
    supply: u64,
    // TODO storageMap doesnt currently work in libs
    // balances: StorageMap<Address, u64>, 
}
const BALANCE_SALT: b256 = 0x0000000000000000000000000000000000000000000000000000000000000ba1;

fn temp_balance_insert(key: Address, val: u64) {
    let slot = sha256((BALANCE_SALT, key));
    store::<u64>(slot, val);
}

fn temp_balance_get(key: Address) -> u64 {
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
    from: Address,
    to: Address,
    amount: u64,
}

pub fn mint_tokens(to: Address, mint_amount: u64) {
    storage.supply = storage.supply + mint_amount;
    let curr_balance = get_balance(to);
    // storage.balances.insert(to, mint_amount + curr_balance);
    temp_balance_insert(to, mint_amount + curr_balance);
    log(Mint {
        amount: mint_amount
    });
}

pub fn burn_tokens(from: Address, burn_amount: u64) {
    let curr_balance = get_balance(from);
    if burn_amount > curr_balance {
        revert(0);
    }
    storage.supply = storage.supply - burn_amount;
    // storage.balances.insert(from, curr_balance - burn_amount);
    temp_balance_insert(from, curr_balance - burn_amount);
    log(Burn {
        amount: burn_amount
    });
}

// TODO convert to use the Identity pattern from the std lib 
pub fn transfer(from: Address, to: Address, amount: u64) {
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

pub fn get_balance(of: Address) -> u64 {
    return temp_balance_get(of);
}

pub fn get_total_supply() -> u64 {
    return storage.supply;
}
