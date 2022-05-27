contract;
use swaypal::fungible_token::*;
use std::address::Address;

abi TestToken {
    fn mint(amount: u64);
    fn burn(amount: u64);
    fn transferTokens(from: Address, to: Address, amount: u64);
    fn balance_of(owner: Address) -> u64;
}

impl TestToken for Contract {
    fn mint(amount: u64) {
        mint_tokens(10);
    }

    fn burn(amount: u64) {
        burn_tokens(10);
    }

    fn transferTokens(from: Address, to: Address, amount: u64) {
        transfer(from, to, amount)
    }

    fn balance_of(owner: Address) -> u64 {
        get_balance(owner)
    }
}
