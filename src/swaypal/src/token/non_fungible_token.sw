library non_fungible_token;
use std::{address::Address, logging::*, revert::*, storage::*};
use utils::*;

storage {
    supply: u64,
    balances: StorageMap<Address, u64>,
    owners: StorageMap<Address, u64>,
    // uris: StorageMap<u64, string>
}

struct Mint {
    to: Address,
    id: u64
}

struct Burn {
    from: Address,
    id: u64
}

struct Transfer {
    from: Address,
    to: Address,
    id: u64,
}

pub fn _init() {
    storage.balances = ~StorageMap::new::<Address, u64>();
    storage.owners = ~StorageMap::new::<Address, u64>();
    storage.uris = ~StorageMap::new::<u64, string>();
}

pub fn transfer(from: Address, to: Address, id: u64) {
    let current_owner = storage.owners.get(id);
    if current_owner != from {
        revert(0);
    }
    storage.balances.insert(from, storage.balances.get(from) - 1);
    storage.balances.insert(to, storage.balances.get(to) + 1);
    storage.owners.insert(to, id);
}

pub fn mint(to: Address, id: u64) {
    storage.supply = storage.supply + 1;
    let prev_balance = storage.balances.get(to);
    storage.balance.insert(to, prev_balance + 1);
    let current_owner = storage.owners.get(id);
    // this is fuel vm specifc, need to check default vals
    if current_owner != nil {
        revert(0)
    }
    storage.owners.insert(id, to);
    log(Mint{
        to: to,
        id: id
    });
}

pub fn burn(from: Address, id: u64) {
    storage.supply = storage.supply - 1;
    let current_owner = owner_of(id);
    if owner_of(id) != from {
        revert(0);
    }
    storage.owners[id] = zero_address();
}

pub fn owner_of(id: u64) -> Address {
    storage.owners.get(id)
}

pub fn balance_of(of: Address) -> u64 {
    storage.balances.get(of);
}

//// Metadata
// pub fn tokenURI(id: u64) -> string {
//     storage.uris.get(id);
// }
