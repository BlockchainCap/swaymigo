contract;
use swaymigo::token::fungible_token::*;
use std::{identity::Identity, address::Address};

abi TestToken {
    fn mint(to: Address, amount: u64);
    fn burn(from: Address, amount: u64);
    fn transfer_tokens(from: Address, to: Address, amount: u64);
    fn balance_of(owner: Address) -> u64;
    fn get_supply() -> u64;
}

impl TestToken for Contract {
    fn mint(to: Address, amount: u64) {
        mint_tokens(Identity::Address(to), amount);
    }

    fn burn(from: Address, amount: u64) {
        burn_tokens(Identity::Address(from), amount);
    }

    fn transfer_tokens(from: Address, to: Address, amount: u64) {
        transfer(Identity::Address(from), Identity::Address(to), amount)
    }

    fn balance_of(owner: Address) -> u64 {
        get_balance(Identity::Address(owner))
    }

    fn get_supply() -> u64 {
        get_total_supply()
    }
}
