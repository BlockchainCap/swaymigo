contract;
use swaymigo::token::vote_token::*;
use std::{block::*, identity::Identity, address::Address};

abi VoteToken {
    fn _mint(to: Address, amount: u64);
    fn _burn(from: Address, amount: u64);
    fn _delegate(from: Address, to: Address, amount: u64);
    fn _transfer(from: Address, to: Address, amount: u64);
    fn _get_supply_checkpoint(block: u64) -> u64;
    fn _get_voting_power(block: u64, voter: Address) -> u64;

    fn blocknumber() -> u64;
    // fn checkpt(index: u64) -> Checkpoint;
    // fn get_sup_count() -> u64;
}

impl VoteToken for Contract {
    fn _mint(to: Address, amount: u64) {
        mint(Identity::Address(to), amount);
    }
    fn _burn(from: Address, amount: u64) {
        burn(Identity::Address(from), amount);
    }
    fn _delegate(from: Address, to: Address, amount: u64) {
        delegate(Identity::Address(from), Identity::Address(to), amount);
    }
    fn _transfer(from: Address, to: Address, amount: u64) {
        transfer_snapshot(Identity::Address(from), Identity::Address(to), amount);
    }
    fn _get_supply_checkpoint(block: u64) -> u64 {
        get_supply_checkpoint(block)
    }
    fn _get_voting_power(block: u64, voter: Address) -> u64 {
        get_voting_power(block, Identity::Address(voter))
    }

    // // testing utilities
    fn blocknumber() -> u64 {
        height()
    }
    // fn checkpt(index: u64) -> Checkpoint {
    //     temp_get_total_supply_snapshot(index)
    // }

    // fn get_sup_count() -> u64 {
    //     temp_get_total_supply_count()
    // }
}
