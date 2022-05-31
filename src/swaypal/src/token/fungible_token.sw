library fungible_token;
use std::{address::Address, hash::*, logging::*, revert::*, storage::*};

const BALANCES_MAPPING = 0x0000000000000000000000000000000000000000000000000000000000000001;

storage {
    supply: u64,
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

// Do this in a seperate module
pub fn mint_tokens(mint_amount: u64, to: Address) {
    storage.supply = storage.supply + mint_amount;
    log(Mint {
        amount: mint_amount
    });
}

// not really sure if we need burn and if it should actually have a 'from'
pub fn burn_tokens(burn_amount: u64, from: Address) {
    storage.supply = storage.supply - burn_amount;
    log(Burn {
        amount: burn_amount
    });
}

pub fn transfer(from: Address, to: Address, amount: u64) {
    if get_balance(from) >= amount {
        let sender_pre_balance = get_balance(from);
        let receiver_pre_balance = get_balance(to);
        store_balance(from, sender_pre_balance - amount);
        store_balance(to, receiver_pre_balance + amount);
        log(Transfer {
            from: from, to: to, amount: amount
        });
    } else {
        revert(0);
    }
}

pub fn get_balance(of: Address) -> u64 {
    return get::<u64>(sha256((BALANCES_MAPPING, of)));
}

pub fn get_total_supply() -> u64 {
    return storage.supply;
}

/// internals
fn store_balance(of: Address, amount: u64) {
    store::<u64>(sha256((BALANCES_MAPPING, of)), amount);
}
