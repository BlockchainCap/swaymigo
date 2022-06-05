library vote_token;

use ::token::fungible_token::*;
use std::{
    address::Address,
    assert::*,
    block::*,
    chain::auth::msg_sender,
    context::balance_of,
    contract_id::ContractId,
    hash::sha256,
    logging::*,
    option::Option,
    storage::*,
};

/// TODO: replace with StorageMap when it is available in libraries
const SUPPLY_CHECKPOINTS: b256 = 0x7000000000000000000001233000000000000000000000000000000000000001;
const SUPPLY_CHECKPOINTS_COUNT: b256 = 0x7000000000000000000009873000000000000000000000000000000000000001;
const TOTAL_SUPPLY: b256 = 0x6900000000000000000000000000000000000000000000000000000000000001;
const VOTER_CHECKPOINTS: b256 = 0x3000000000000000000000000000000000000000000000000000000000000002;
const VOTER_CHECKPOINT_COUNTS: b256 = 0x7200000000000000000000000000000000000000000000000000000000000003;

struct Checkpoint {
    block: u64,
    value: u64,
}

/// internal methods to replace insert and get on StorageMap, these should not contain logic beyond what storagemap would do
fn temp_insert_total_supply(supply: u64) {
    store::<u64>(sha256(TOTAL_SUPPLY), supply);
}
fn temp_get_total_supply() -> u64 {
    get::<u64>(sha256(TOTAL_SUPPLY))
}
fn temp_insert_total_supply_count(count: u64) {
    store::<u64>(sha256(SUPPLY_CHECKPOINTS_COUNT), count);
}
fn temp_get_total_supply_count() -> u64 {
    get::<u64>(sha256(SUPPLY_CHECKPOINTS_COUNT))
}
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
    let key = sha256((VOTER_CHECKPOINTS, voter, index));
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
fn insert_checkpoint(key: b256, checkpoint: Checkpoint) {
    let block_slot = sha256((key, "block"));
    let value_slot = sha256((key, "value"));

    store::<u64>(block_slot, checkpoint.block);
    store::<u64>(value_slot, checkpoint.value);
}
fn get_checkpoint(key: b256) -> Checkpoint {
    let block_slot = sha256((key, "block"));
    let value_slot = sha256((key, "value"));

    let block = get::<u64>(block_slot);
    let value = get::<u64>(value_slot);
    Checkpoint {
        block: block,
        value: value,
    }
}

//// PUBLIC FUNCTIONS
pub fn mint(to: Address, mint_amount: u64) {
    mint_tokens(to, mint_amount);
    // storage.total_supply = storage.total_supply + mint_amount;
    temp_insert_total_supply(temp_get_total_supply() + mint_amount);
    temp_insert_total_supply_snapshot(temp_get_total_supply_count(), Checkpoint {
        block: height(), value: temp_get_total_supply()
    });
    let to_checkpoint_count = temp_get_voter_checkpoint_count(to);
    temp_insert_voter_balance(to, to_checkpoint_count, Checkpoint {
        block: height(), value: get_balance(to)
    });
    temp_insert_voter_checkpoint_count(to, to_checkpoint_count + 1);
    // storage.num_checkpoints = storage.num_checkpoints + 1;
    temp_insert_total_supply_count(temp_get_total_supply_count() + 1);
}

pub fn burn(from: Address, burn_amount: u64) {
    burn_tokens(from, burn_amount);
    temp_insert_total_supply(temp_get_total_supply() - burn_amount);
    temp_insert_total_supply_snapshot(temp_get_total_supply_count(), Checkpoint {
        block: height(), value: temp_get_total_supply()
    });
    let from_checkpoint_count = temp_get_voter_checkpoint_count(from);
    temp_insert_voter_balance(from, from_checkpoint_count, Checkpoint {
        block: height(), value: get_balance(from)
    });
    // storage.num_checkpoints = storage.num_checkpoints + 1;
    temp_insert_total_supply_count(temp_get_total_supply_count() + 1);
    temp_insert_voter_checkpoint_count(from, from_checkpoint_count + 1);
}

pub fn transfer_snapshot(from: Address, to: Address, amount: u64) {
    transfer(from, to, amount);
    // snapshot logic, this is equivalent to delegation
    delegate(from, to, amount);
}

// prob should be keeping track of all delegations
pub fn delegate(from: Address, to: Address, amount: u64) {
    let from_num_checkpoints = temp_get_voter_checkpoint_count(from);
    let from_latest_checkpoint = temp_get_voter_balance(from, from_num_checkpoints);
    temp_insert_voter_balance(from, from_num_checkpoints, Checkpoint {
        value: from_latest_checkpoint.value - amount, block: height()
    });
    temp_insert_voter_checkpoint_count(from, from_num_checkpoints + 1);

    let to_num_checkpoint = temp_get_voter_checkpoint_count(to);
    let to_latest_checkpoint = temp_get_voter_balance(to, to_num_checkpoint);
    temp_insert_voter_balance(to, to_num_checkpoint, Checkpoint {
        value: to_latest_checkpoint.value + amount, block: height()
    });
    temp_insert_voter_checkpoint_count(to, to_num_checkpoint + 1);
}

pub fn get_supply_checkpoint(block: u64) -> u64 {
    assert(block < height());
    let mut high = temp_get_total_supply_count();
    let mut low = 0;
    while low < high {
        let mid = (high + low) / 2;
        let checkpoint = temp_get_total_supply_snapshot(mid);
        if checkpoint.block > block {
            high = mid
        } else {
            low = mid + 1
        };
    }
    return if high == 0 {
        0
    } else {
        let last_cp = temp_get_total_supply_snapshot(high - 1);
        last_cp.value
    }
}

// lots of duplicated code here, should make generic binary search
pub fn get_voting_power(block: u64, address: Address) -> u64 {
    assert(block < height());
    let mut high = temp_get_voter_checkpoint_count(address);
    let mut low = 0;
    while low < high {
        let mid = (high + low) / 2;
        let checkpoint = temp_get_voter_balance(address, mid);
        if checkpoint.block > block {
            high = mid
        } else {
            low = mid + 1 
        };
    }
    return if high == 0 {
        0
    } else {
        let last_cp = temp_get_voter_balance(address, high - 1);
        last_cp.value
    }
}
