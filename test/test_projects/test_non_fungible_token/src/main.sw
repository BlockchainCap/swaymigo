contract;
use std::identity::Identity;
use swaymigo::token::non_fungible_token::*;

abi TestNFT {
    fn _mint(to: Identity, id: u64);
    fn _burn(from: Identity, id: u64);
    fn _owner_of(id: u64) -> Identity;
    fn _balance_of(of: Identity) -> u64;
    fn _supply() -> u64;
    fn _transfer(from: Identity, to: Identity, id: u64);

    fn test() -> bool;
}

impl TestNFT for Contract {
    fn _mint(to: Identity, id: u64) {
        mint(to, id);
    }

    fn _burn(from: Identity, id: u64) {
        burn(from, id);
    }

    fn _owner_of(id: u64) -> Identity {
        owner_of(id)
    }

    fn _balance_of(of: Identity) -> u64 {
        balance_of(of)
    }

    fn _supply() -> u64 {
        get_supply()
    }

    fn _transfer(from: Identity, to: Identity, id: u64) {
        transfer(from, to, id)
    }

    fn test() -> bool {
        false
    }
}
