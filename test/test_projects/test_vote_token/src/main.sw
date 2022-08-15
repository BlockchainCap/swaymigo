contract;
use swaymigo::token::vote_token::*;
use std::{address::Address, block::*, identity::Identity};

abi VoteToken {
    #[storage(read, write)]fn _mint(to: Address, amount: u64);
    #[storage(read, write)]fn _burn(from: Address, amount: u64);
    #[storage(read, write)]fn _delegate(from: Address, to: Address, amount: u64);
    #[storage(read, write)]fn _transfer(from: Address, to: Address, amount: u64);
    #[storage(read)]fn _get_supply_checkpoint(block: u64) -> u64;
    #[storage(read)]fn _get_voting_power(block: u64, voter: Address) -> u64;

    fn blocknumber() -> u64;
    // fn checkpt(index: u64) -> Checkpoint;
    // fn get_sup_count() -> u64;
}

impl VoteToken for Contract {
    #[storage(read, write)]fn _mint(to: Address, amount: u64) {
        mint(Identity::Address(to), amount);
    }
    #[storage(read, write)]fn _burn(from: Address, amount: u64) {
        burn(Identity::Address(from), amount);
    }
    #[storage(read, write)]fn _delegate(from: Address, to: Address, amount: u64) {
        delegate(Identity::Address(from), Identity::Address(to), amount);
    }
    #[storage(read, write)]fn _transfer(from: Address, to: Address, amount: u64) {
        transfer(Identity::Address(from), Identity::Address(to), amount);
    }
    #[storage(read)]fn _get_supply_checkpoint(block: u64) -> u64 {
        get_supply_checkpoint(block)
    }
    #[storage(read)]fn _get_voting_power(block: u64, voter: Address) -> u64 {
        get_voting_power(block, Identity::Address(voter))
    }

    // // testing utilities
    fn blocknumber() -> u64 {
        height()
    }
}
