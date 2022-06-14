contract;
use swaymigo::token::vote_token::*;
use std::{identity::Identity, block::*};

abi VoteToken {
    fn _mint(to: Identity, amount: u64);
    fn _burn(from: Identity, amount: u64);
    fn _delegate(from: Identity, to: Identity, amount: u64);
    fn _transfer(from: Identity, to: Identity, amount: u64);
    fn _get_supply_checkpoint(block: u64) -> u64;
    fn _get_voting_power(block: u64, voter: Identity) -> u64;

    fn blocknumber() -> u64;
    // fn checkpt(index: u64) -> Checkpoint;
    // fn get_sup_count() -> u64;
}

impl VoteToken for Contract {
    fn _mint(to: Identity, amount: u64) {
        mint(to, amount);
    }
    fn _burn(from: Identity, amount: u64) {
        burn(from, amount);
    }
    fn _delegate(from: Identity, to: Identity, amount: u64) {
        delegate(from, to, amount);
    }
    fn _transfer(from: Identity, to: Identity, amount: u64) {
        transfer_snapshot(from, to, amount);
    }
    fn _get_supply_checkpoint(block: u64) -> u64 {
        get_supply_checkpoint(block)
    }
    fn _get_voting_power(block: u64, voter: Identity) -> u64 {
        get_voting_power(block, voter)
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
