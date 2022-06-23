contract;
use swaymigo::token::ledger_fungible_token::*;
use std::{identity::Identity, address::Address};

abi TestToken {
    #[storage(read, write)]
    fn mint(to: Address, amount: u64);
    #[storage(read, write)]
    fn burn(from: Address, amount: u64);
    #[storage(read, write)]
    fn transfer_tokens(from: Address, to: Address, amount: u64);
    #[storage(read)]
    fn balance_of(owner: Address) -> u64;
    #[storage(read)]
    fn get_supply() -> u64;
}

impl TestToken for Contract {
    #[storage(read, write)]
    fn mint(to: Address, amount: u64) {
        mint_tokens(Identity::Address(to), amount);
    }

    #[storage(read, write)]
    fn burn(from: Address, amount: u64) {
        burn_tokens(Identity::Address(from), amount);
    }

    #[storage(read, write)]
    fn transfer_tokens(from: Address, to: Address, amount: u64) {
        f_transfer(Identity::Address(from), Identity::Address(to), amount)
    }

    #[storage(read)]
    fn balance_of(owner: Address) -> u64 {
        get_balance(Identity::Address(owner))
    }

    #[storage(read)]
    fn get_supply() -> u64 {
        get_total_supply()
    }
}
