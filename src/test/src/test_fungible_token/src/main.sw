contract;
use swaypal::token::fungible_token::*;
use std::address::Address;

abi TestToken {
    fn mint(amount: u64, to: Address);
    fn burn(amount: u64, from: Address);
    fn transfer_tokens(from: Address, to: Address, amount: u64);
    fn balance_of(owner: Address) -> u64;
}

impl TestToken for Contract {
    fn mint(amount: u64, to: Address) {
        mint_tokens(amount, to);
    }

    fn burn(amount: u64, from: Address) {
        burn_tokens(amount, from);
    }

    fn transfer_tokens(from: Address, to: Address, amount: u64) {
        transfer(from, to, amount)
    }

    fn balance_of(owner: Address) -> u64 {
        get_balance(owner)
    }
}
