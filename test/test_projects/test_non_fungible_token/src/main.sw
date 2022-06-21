contract;
use std::{address::Address, identity::Identity, revert::*};
use swaymigo::token::non_fungible_token::*;

abi TestNFT {
    #[storage(read, write)]
    fn _mint(to: Address, id: u64);
    #[storage(read, write)]
    fn _burn(from: Address, id: u64);
    #[storage(read, write)]
    fn _transfer(from: Address, to: Address, id: u64);
    #[storage(read)]
    fn _owner_of(id: u64) -> Address;
    #[storage(read)]
    fn _balance_of(of: Address) -> u64;
    #[storage(read)]
    fn _supply() -> u64;
}

impl TestNFT for Contract {
    #[storage(read, write)]
    fn _mint(to: Address, id: u64) {
        mint(Identity::Address(to), id);
    }

    #[storage(read, write)]
    fn _burn(from: Address, id: u64) {
        burn(Identity::Address(from), id);
    }

    #[storage(read, write)]
    fn _transfer(from: Address, to: Address, id: u64) {
        transfer(Identity::Address(from), Identity::Address(to), id)
    }

    #[storage(read)]
    fn _owner_of(id: u64) -> Address {
        let owner = owner_of(id);
        match owner {
            Identity::Address(owner) => {owner},
            Identity::ContractId(owner) => {revert(0)}
        }
    }

    #[storage(read)]
    fn _balance_of(of: Address) -> u64 {
        balance_of(Identity::Address(of))
    }

    #[storage(read)]
    fn _supply() -> u64 {
        get_supply()
    }

}
