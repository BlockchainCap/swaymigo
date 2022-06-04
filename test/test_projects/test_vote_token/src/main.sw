contract;
use swaypal::token::vote_token::*;
use std::{address::Address, block::*};

abi VoteToken {
    fn _mint(to: Address, amount: u64);
    fn _burn(from: Address, amount: u64);
    fn _delegate(from: Address, to: Address, amount: u64);
    fn _transfer(from: Address, to: Address, amount: u64);
    fn _get_supply_checkpoint(block: u64) -> u64;
    fn _get_voting_power(block: u64, voter: Address) -> u64;

    fn blocknumber() -> u64;
    fn checkpt(index: u64) -> Checkpoint;  
}

impl VoteToken for Contract {
    fn _mint(to: Address, amount: u64) {
        mint(to, amount);
    }
    fn _burn(from: Address, amount: u64) {
        burn(from, amount);
    }
    fn _delegate(from: Address, to: Address, amount: u64) {
        delegate(from, to, amount);
    }
    fn _transfer(from: Address, to: Address, amount: u64) {
        transfer_snapshot(from, to, amount);
    }
    fn _get_supply_checkpoint(block: u64) -> u64 {
        get_supply_checkpoint(block)
    }
    fn _get_voting_power(block: u64, voter: Address) -> u64 {
        get_voting_power(block, voter)
    }

    // testing utilities
    fn blocknumber() -> u64 {
        height()
    }
    fn checkpt(index: u64) -> Checkpoint {
        temp_get_total_supply_snapshot(index)
    }

}
