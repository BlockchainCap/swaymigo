library non_fungible_token;
use std::{
    assert::*,
    chain::auth::msg_sender,
    contract_id::*,
    hash::*,
    identity::*,
    logging::*,
    revert::*,
    storage::*,
};

use ::auth::zero_address::get_zero_address;
use ::auth::sender::*;

// TODO: Upgrade to storage keyword when available
// storage {
//     supply: u64,
//     // balances: StorageMap<Identity, u64>,
//     // owners: StorageMap<u64, Identity>
// }

const SUPPLY_SALT: b256 = 0x0afafa0000000000000000000000000000000000000000000000000000000ba1;
const BALANCE_SALT: b256 = 0x0000000000000000000000000000000000000000000000000000000000000ba1;
const OWNER_SALT: b256 = 0x0000000000000000000000000000000000000000000000000000000000000002;

#[storage(read)]fn temp_get_supply() -> u64 {
    get::<u64>(SUPPLY_SALT)
}

#[storage(write)]fn temp_set_supply(s: u64) {
    store::<u64>(SUPPLY_SALT, s);
}

#[storage(write)]fn temp_balance_insert(key: Identity, val: u64) {
    let slot = sha256((BALANCE_SALT, key));
    store::<u64>(slot, val);
}

#[storage(read)]fn temp_balance_get(key: Identity) -> u64 {
    let slot = sha256((BALANCE_SALT, key));
    get::<u64>(slot)
}

#[storage(write)]fn temp_owner_insert(id: u64, owner: Identity) {
    let slot = sha256((OWNER_SALT, id));
    store::<Identity>(slot, owner);
}

#[storage(read)]fn temp_owner_get(id: u64) -> Identity {
    let slot = sha256((OWNER_SALT, id));
    get::<Identity>(slot)
}

struct Mint {
    to: Identity,
    id: u64,
}

struct Burn {
    from: Identity,
    id: u64,
}

struct Transfer {
    from: Identity,
    to: Identity,
    id: u64,
}

enum Error {
    NotOwner: (),
    TokenAlreadyExists: (),
}

#[storage(read, write)]pub fn transfer(from: Identity, to: Identity, id: u64) {
    let current_owner = owner_of(id);
    let sender = get_msg_sender_id_or_panic(msg_sender());
    require(from == sender, Error::NotOwner());
    require(current_owner == from, Error::NotOwner());
    temp_balance_insert(from, balance_of(from) - 1);
    temp_balance_insert(to, balance_of(to) + 1);
    temp_owner_insert(id, to);
    log(Transfer {
        from: from, to: to, id: id
    });
}

#[storage(read, write)]pub fn mint(to: Identity, id: u64) {
    // storage.supply = storage.supply + 1;
    temp_set_supply(temp_get_supply() + 1);
    let prev_balance = balance_of(to);
    temp_balance_insert(to, prev_balance + 1);
    let current_owner = owner_of(id);
    require(current_owner == get_zero_address(), Error::TokenAlreadyExists());
    temp_owner_insert(id, to);
    log(Mint {
        to: to, id: id
    });
}

#[storage(read, write)]pub fn burn(from: Identity, id: u64) {
    // storage.supply = storage.supply - 1;
    temp_set_supply(temp_get_supply() - 1);
    let current_owner = owner_of(id);
    let sender = get_msg_sender_id_or_panic(msg_sender());
    // require(sender.into() == from, Error::NotOwner());
    require(current_owner == from, Error::NotOwner());
    temp_owner_insert(id, get_zero_address());
    temp_balance_insert(from, temp_balance_get(from) - 1);
    log(Burn {
        from: from, id: id
    });
}

#[storage(read)]pub fn owner_of(id: u64) -> Identity {
    temp_owner_get(id)
}

#[storage(read)]pub fn balance_of(of: Identity) -> u64 {
    temp_balance_get(of)
}

#[storage(read)]pub fn get_supply() -> u64 {
    return temp_get_supply();
}
//// Metadata
// pub fn tokenURI(id: u64) -> string {
//     storage.uris.get(id);
// }
