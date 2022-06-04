library balance_snapshot_token;
// this is a token that keeps a index of all historical balances and total supply.
// this is important for using tokens to vote

use ::token::fungible_token::*;
use std::{
    address::Address,
    block::*,
    chain::auth::msg_sender,
    context::balance_of,
    contract_id::ContractId,
    hash::sha256,
    logging::*,
    option::Option,
    storage::*,
};

storage {
    num_checkpoints: u64,
    total_supply: u64,
}

/// TODO: replace with StorageMap when it is available in libraries
// mapping of index => checkpoint. contains total supply checkpoints
const SUPPLY_CHECKPOINTS: b256 = 0x7000000000000000000000000000000000000000000000000000000000000001;
// mapping for sha(user, user_index) => checkpoint. Contains all checkpoints for a given user
const VOTER_CHECKPOINTS = 0x0000000000000000000000000000000000000000000000000000000000000002;
// mapping of user to their number of checkpoints.
const VOTER_CHECKPOINT_COUNTS = 0x0000000000000000000000000000000000000000000000000000000000000003;
// storage mapping for everyones balances
const BALANCES = 0x0000000000000000000000000000000000000000000000000000000000000004;

struct Checkpoint {
    block: u64,
    value: u64,
}

/// internal methods to replace insert and get on StorageMap, these should not contain logic beyond what storagemap would do
fn temp_insert_total_supply_snapshot(index: u64, checkpoint: Checkpoint) {
    let key = sha256((SUPPLY_CHECKPOINTS, index));
    insert_checkpoint(key, checkpoint);
}
fn temp_get_total_supply_snapshot(index: u64) -> Checkpoint {
    let key = sha256((SUPPLY_CHECKPOINTS, index));
    get_checkpoint(key)
}
fn temp_insert_voter_balance(voter: Address, index: u64, checkpoint: Checkpoint) {
    let key = sha256((VOTER_CHECKPOINTS, voter, index));
    insert_checkpoint(key, checkpoint);
}
fn temp_get_voter_balance(voter: Address, index: u64) -> Checkpoint {
    let key = sha256((VOTER_CHECKPOINTS, index));
    get_checkpoint(key)
}
fn temp_insert_voter_checkpoint_count(voter: Address, count: u64) {
    let key = sha256((VOTER_CHECKPOINT_COUNTS, voter));
    store::<u64>(key, count);
}
fn temp_get_voter_checkpoint_count(voter: Address) -> u64 {
    let key = sha256((VOTER_CHECKPOINT_COUNTS, voter));
    get::<u64>(key)
}
// the checkpoints for every time the total supply changes
fn insert_checkpoint(key: b256, checkpoint: Checkpoint) {
    // storing a struct is also broken
    let block_slot = sha256((key, "block"));
    let value_slot = sha256((key, "value"));

    store::<u64>(block_slot, checkpoint.block);
    store::<u64>(value_slot, checkpoint.value);
}

fn get_checkpoint(key: b256) -> Checkpoint {
    // storing a struct is also not supported yet
    let block_slot = sha256((key, "block"));
    let value_slot = sha256((key, "value"));

    let block = get::<u64>(block_slot);
    let value = get::<u64>(value_slot);
    Checkpoint {
        block: block,
        value: value,
    }
}

pub fn mint(to: Address, mint_amount: u64) {
    mint_tokens(to, mint_amount);
    storage.total_supply = storage.total_supply + mint_amount;
    storage.num_checkpoints = storage.num_checkpoints + 1;
    temp_insert_total_supply_snapshot(storage.num_checkpoints, Checkpoint {
        block: height(), value: storage.total_supply
    });
    let to_checkpoint_count = temp_get_voter_checkpoint_count(to);
    temp_insert_voter_balance(to, to_checkpoint_count + 1, Checkpoint {
        block: height(), value: get_balance(to)
    });
    temp_insert_voter_checkpoint_count(to, to_checkpoint_count + 1);
}

pub fn burn(from: Address, burn_amount: u64) {
    burn_tokens(from, burn_amount);
    storage.total_supply = storage.total_supply - burn_amount;
    storage.num_checkpoints = storage.num_checkpoints + 1;
    temp_insert_total_supply_snapshot(storage.num_checkpoints, Checkpoint {
        block: height(), value: storage.total_supply
    });
    let from_checkpoint_count = temp_get_voter_checkpoint_count(from);
    temp_insert_voter_balance(from, from_checkpoint_count + 1, Checkpoint {
        block: height(), value: get_balance(from)
    });
    temp_insert_voter_checkpoint_count(from, from_checkpoint_count + 1);
}

pub fn transfer_snapshot(from: Address, to: Address, amount: u64) {
    transfer(from, to, amount);
    // snapshot logic
}

pub fn lookup_supply_checkpoint(block: u64) -> u64 {
    let mut high = storage.num_checkpoints;
    let mut low = 0;
    while low < high {
        let mid = (high + low) / 2;
        let checkpoint = temp_get_total_supply_snapshot(mid);
        if checkpoint.block > block {
            high = mid
        } else {
            low = mid
        };
    }
    return if high == 0 {
        0
    } else {
        let last_cp = temp_get_total_supply_snapshot(high - 1);
        last_cp.value
    }
}
/// Binary search to find the earliest checkpoint taken after the block provided
pub fn lookup_voter_checkpoint(block: u64, address: Address) -> u64 {
    let mut high = storage.num_checkpoints;
    let mut low = 0;
    while low < high {
        let mid = (high + low) / 2;
        let checkpoint = temp_get_voter_balance(address, mid);
        if checkpoint.block > block {
            high = mid
        } else {
            low = mid
        };
    }
    return if high == 0 {
        0
    } else {
        let last_cp = temp_get_voter_balance(address, high - 1);
        last_cp.value
    }
}
