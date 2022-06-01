contract;
use std::address::Address;
use swaypal::token::non_fungible_token::*;

abi TestNFT {
    fn mint(to: Address, id: u64);
    fn burn(from: Address, id: u64);
    fn owner_of(id: u64) -> Address;
    fn balance_of(of: Address) -> u64;
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
}
