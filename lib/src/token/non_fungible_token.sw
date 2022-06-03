library non_fungible_token;
use std::{address::Address, hash::*, logging::*, revert::*, storage::*};
use ::auth::zero_address::get_zero_address;

storage {
    supply: u64,
    // balances: StorageMap<Address, u64>,
    // owners: StorageMap<u64, Address>
}

const BALANCE_SALT: b256 = 0x0000000000000000000000000000000000000000000000000000000000000ba1;
const OWNER_SALT: b256 = 0x0000000000000000000000000000000000000000000000000000000000000002;

fn temp_balance_insert(key: Address, val: u64) {
    let slot = sha256((BALANCE_SALT, key));
    store::<u64>(slot, val);
}

fn temp_balance_get(key: Address) -> u64 {
    let slot = sha256((BALANCE_SALT, key));
    get::<u64>(slot)
}

fn temp_owner_insert(id: u64, owner: Address) {
    let slot = sha256((OWNER_SALT, id));
    store::<Address>(slot, owner);
}

fn temp_owner_get(id: u64) -> Address {
    let slot = sha256((OWNER_SALT, id));
    get::<Address>(slot)
}

struct Mint {
    to: Address,
    id: u64,
}

struct Burn {
    from: Address,
    id: u64,
}

struct Transfer {
    from: Address,
    to: Address,
    id: u64,
}

pub fn transfer(from: Address, to: Address, id: u64) {
    let current_owner = owner_of(id);
    if current_owner != from {
        revert(0);
    }
    temp_balance_insert(from, balance_of(from) - 1);
    temp_balance_insert(to, balance_of(to) + 1);
    temp_owner_insert(id, to);
    log(Transfer {
        from: from, to: to, id: id
    });
}

pub fn mint(to: Address, id: u64) {
    storage.supply = storage.supply + 1;
    let prev_balance = balance_of(to);
    temp_balance_insert(to, prev_balance + 1);
    let current_owner = owner_of(id);
    // this is fuel vm specifc, need to check default vals
    // if current_owner != nil {
    //     revert(0)
    // }
    temp_owner_insert(id, to);
    log(Mint {
        to: to, id: id
    });
}

pub fn burn(from: Address, id: u64) {
    storage.supply = storage.supply - 1;
    let current_owner = owner_of(id);
    if owner_of(id) != from {
        revert(0);
    }
    temp_owner_insert(id, get_zero_address());
    log(Burn {
        from: from, id: id
    });
}

pub fn owner_of(id: u64) -> Address {
    temp_owner_get(id)
}

pub fn balance_of(of: Address) -> u64 {
    temp_balance_get(of)
}

//// Metadata
// pub fn tokenURI(id: u64) -> string {
//     storage.uris.get(id);
// }
