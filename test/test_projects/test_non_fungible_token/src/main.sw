contract;
use std::{address::Address, identity::Identity, revert::*};
use swaymigo::token::non_fungible_token::*;

abi TestNFT {
    #[storage(read, write)]fn _mint(to: Identity, id: u64);
    #[storage(read, write)]fn _burn(from: Identity, id: u64);
    #[storage(read, write)]fn _transfer(from: Identity, to: Identity, id: u64);
    #[storage(read)]fn _owner_of(id: u64) -> Identity;
    #[storage(read)]fn _balance_of(of: Identity) -> u64;
    #[storage(read)]fn _supply() -> u64;
}

impl TestNFT for Contract {
    #[storage(read, write)]fn _mint(to: Identity, id: u64) {
        mint(to, id);
    }

    #[storage(read, write)]fn _burn(from: Identity, id: u64) {
        burn(from, id);
    }

    #[storage(read, write)]fn _transfer(from: Identity, to: Identity, id: u64) {
        transfer(from, to, id)
    }

    #[storage(read)]fn _owner_of(id: u64) -> Identity {
        owner_of(id)
    }

    #[storage(read)]fn _balance_of(of: Identity) -> u64 {
        balance_of(of)
    }

    #[storage(read)]fn _supply() -> u64 {
        get_supply()
    }
}
