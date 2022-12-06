library vault;
use std::{
    assert::*,
    auth::*,
    context::*,
    call_frames::*,
    contract_id::ContractId,
    hash::*,
    identity::*,
    logging::*,
    storage::*,
    token::*,
};

use ::auth::sender::*;

struct Deposit {
    caller: Identity,
    receiver: Identity,
    assets: u64,
    shares: u64,
}

struct Withdraw {
    caller: Identity,
    receiver: Identity,
    owner: Identity,
    assets: u64,
    shares: u64,
}

enum Error {
    IncorrectAsset: (),
    InsuffienctShares: (),
}

// receive asset, mint the shares
#[storage(read, write)]pub fn deposit(receiver: Identity) {
    assert(msg_amount() > 0);
    let caller = get_msg_sender_id_or_panic(msg_sender());
    // note that this lib function does not check the token being deposited.
    let assets = msg_amount();
    let shares = get_shares_from_assets(assets, msg_asset_id());
    assert(shares > 0);
    // TEST: I think this is unnessesary
    // transfer(assets, msg_asset_id(), Identity::ContractId(contract_id())); // should happen auto
    mint_to(shares, receiver);
    temp_set_share_supply(temp_get_share_supply() + shares);
    log(Deposit {
        caller, receiver, assets, shares
    });
}

// receive shares, return the locked asset
#[storage(read, write)]pub fn withdraw(receiver: Identity, asset_id: ContractId) {
    // TODO: require not available in this scope?
    // require(msg_asset_id().into() == (contract_id()).into(), Error::IncorrectAsset);
    assert(msg_asset_id().into() == (contract_id()).into());
    assert(msg_amount() > 0);
    let shares = msg_amount();
    let caller = get_msg_sender_id_or_panic(msg_sender());
    // shares is the proportion of the pool that is owned based on current supply
    let assets = get_assets_from_shares(shares, asset_id);
    // require(assets > 0, Error::InsuffienctShares);
    assert(assets > 0);
    transfer(assets, asset_id, receiver);
    burn(shares);
    temp_set_share_supply(temp_get_share_supply() - shares);
    log(Withdraw {
        caller, receiver, owner: receiver, assets, shares
    });
}

//// Internals
#[storage(read)]fn get_shares_from_assets(assets: u64, asset_id: ContractId) -> u64 {
    // total assets locked is the balance of the contact
    let locked_amount = this_balance(asset_id); // CHECK: does this get incremented BEFORE the contract logic or AFTER
    // is there a way to query the total shares supply... for now store in contract storage
    let total_shares = temp_get_share_supply();

    if total_shares == 0 {
        assets
    } else {
        // proportional amount of shares based on % of supply
        // need to make this work w int math
        assets * (total_shares / locked_amount)
    }
}

#[storage(read)]fn get_assets_from_shares(shares: u64, asset_id: ContractId) -> u64 {
    // total assets locked is the balance of the contact
    let locked_amount = this_balance(asset_id); // CHECK: does this get incremented BEFORE the contract logic or AFTER
    // user should get a number of shares that is proportional to the
    // is there a way to query the total shares... for now store in contract storage
    let total_shares = temp_get_share_supply();

    if total_shares == 0 {
        shares
    } else {
        // proportional amount of shares based on % of supply
        // need to make this work w int math
        shares * (locked_amount / total_shares)
    }
}

//// STORAGE
const SHARE_SUPPLY: b256 = 0x0123012012302310123012301230123012301230290943898238485820482839;
#[storage(read)]fn temp_get_share_supply() -> u64 {
    get::<u64>(sha256(SHARE_SUPPLY))
}
#[storage(write)]fn temp_set_share_supply(supply: u64) {
    store::<u64>(sha256(SHARE_SUPPLY), supply)
}
