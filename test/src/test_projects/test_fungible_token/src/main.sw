contract;
use swaypal::token::fungible_token::*;
use std::address::Address;

abi TestToken {
    fn mint(to: Address, amount: u64);
    fn burn(from: Address, amount: u64);
    fn transfer_tokens(from: Address, to: Address, amount: u64);
    fn balance_of(owner: Address) -> u64;
    fn get_supply() -> u64;
}

impl TestToken for Contract {
    fn mint(to: Address, amount: u64) {
        mint_tokens(to, amount);
    }

    fn burn(from: Address, amount: u64) {
        burn_tokens(from, amount);
    }

    fn transfer_tokens(from: Address, to: Address, amount: u64) {
        transfer(from, to, amount)
    }

    fn balance_of(owner: Address) -> u64 {
        get_balance(owner)
    }

    fn get_supply() -> u64 {
        get_total_supply()
    }
}
