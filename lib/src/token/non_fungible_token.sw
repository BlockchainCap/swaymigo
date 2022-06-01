library non_fungible_token;
use std::{address::Address, logging::*, revert::*, storage::*};
use ::auth::zero_address::get_zero_address;

storage {
    supply: u64,
    balances: StorageMap<Address,
    u64>, owners: StorageMap<u64,
    Address>, // uris: StorageMap<u64, string>
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
    let current_owner = storage.owners.get(id);
    if current_owner != from {
        revert(0);
    }
    storage.balances.insert(from, storage.balances.get(from) - 1);
    storage.balances.insert(to, storage.balances.get(to) + 1);
    storage.owners.insert(id, to);
    log(Transfer {
        from: from, to: to, id: id
    });
}

pub fn mint(to: Address, id: u64) {
    storage.supply = storage.supply + 1;
    let prev_balance = storage.balances.get(to);
    storage.balances.insert(to, prev_balance + 1);
    let current_owner = storage.owners.get(id);
    // this is fuel vm specifc, need to check default vals
    // if current_owner != nil {
    //     revert(0)
    // }
    storage.owners.insert(id, to);
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
    storage.owners.insert(id, get_zero_address());
    log(Burn {
        from: from, id: id
    });
}

pub fn owner_of(id: u64) -> Address {
    storage.owners.get(id)
}

pub fn balance_of(of: Address) -> u64 {
    storage.balances.get(of)
}

//// Metadata
// pub fn tokenURI(id: u64) -> string {
//     storage.uris.get(id);
// }
