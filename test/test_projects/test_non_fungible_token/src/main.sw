contract;
use std::{address::Address, identity::Identity, revert::*};
use swaymigo::token::non_fungible_token::*;

abi TestNFT {
    fn _mint(to: Address, id: u64);
    fn _burn(from: Address, id: u64);
    fn _owner_of(id: u64) -> Address;
    fn _balance_of(of: Address) -> u64;
    fn _supply() -> u64;
    fn _transfer(from: Address, to: Address, id: u64);

    fn test() -> bool;
}

impl TestNFT for Contract {
    fn _mint(to: Address, id: u64) {
        mint(Identity::Address(to), id);
    }

    fn _burn(from: Address, id: u64) {
        burn(Identity::Address(from), id);
    }

    fn _owner_of(id: u64) -> Address {
        let owner = owner_of(id);
        match owner {
            Identity::Address(owner) => {owner},
            Identity::ContractId(owner) => {revert(0)}
        }
    }

    fn _balance_of(of: Address) -> u64 {
        balance_of(Identity::Address(of))
    }

    fn _supply() -> u64 {
        get_supply()
    }

    fn _transfer(from: Address, to: Address, id: u64) {
        transfer(Identity::Address(from), Identity::Address(to), id)
    }

    fn test() -> bool {
        false
    }
}
