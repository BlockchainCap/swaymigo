contract;
use std::address::Address;
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
        mint(to, id);
    }

    fn _burn(from: Address, id: u64) {
        burn(from, id);
    }

    fn _owner_of(id: u64) -> Address {
        owner_of(id)
    }

    fn _balance_of(of: Address) -> u64 {
        balance_of(of)
    }

    fn _supply() -> u64 {
        get_supply()
    }

    fn _transfer(from: Address, to: Address, id: u64) {
        transfer(from, to, id)
    }

    fn test() -> bool {
        false
    }
}
