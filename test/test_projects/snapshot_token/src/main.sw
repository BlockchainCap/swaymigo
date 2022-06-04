contract;
use swaypal::token::balance_snapshot_token::*;
use std::address::Address;

abi SnapshotToken {
    fn _mint(to: Address, amount: u64);
    fn _burn(from: Address, amount: u64);
    fn _transfer(from: Address, to: Address, amount: u64);
    fn get_supply_checkpoint(block: u64) -> u64;
    fn get_voter_checkpoint(block: u64, voter: Address) -> u64;
}

impl SnapshotToken for Contract {
    fn _mint(to: Address, amount: u64) {
        mint(to, amount);
    }

    fn _burn(from: Address, amount: u64) {
        burn(from, amount);
    }

    fn get_supply_checkpoint(block: u64) -> u64 {
        lookup_supply_checkpoint(block)
    }

    fn get_voter_checkpoint(block: u64, voter: Address) -> u64 {
        lookup_supply_checkpoint(block, voter)
    }

    fn _transfer(from: Address, to: Address, amount: u64) {
        transfer_snapshot(from, to, amount)
    }
}
