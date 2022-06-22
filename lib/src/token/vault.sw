library vault;
use std::{
    assert::*, 
    contract_id::ContractId, 
    chain::auth::*, 
    identity::*, 
    logging::*, 
    storage::*, 
    token::*, 
    context::*, 
    context::call_frames::*};
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

#[storage(read, write)]pub fn deposit(receiver: Identity) {
    let caller = get_msg_sender_id_or_panic(msg_sender());
    // note that this lib function does not check the token being deposited.
    let assets = msg_amount(); 
    let shares = get_shares_from_assets(assets);
    assert(shares > 0);
    mint_to(shares, receiver);
    log(Deposit {
        caller, receiver, assets, shares
    });
}

#[storage(read, write)]pub fn withdraw(receiver: Identity) {
    // the contract id native asset is the share token
    assert(msg_asset_id() == contract_id());
    let assets = msg_amount();
    let caller = get_msg_sender_id_or_panic(msg_sender());
    // shares is the proportion of the pool that is owned based on current supply
    let shares = get_shares_from_assets(assets);
    assert(shares > 0);
    burn(shares);
    // transfer(shares, asset_id, Identity::ContractId(asset_id));
    log(Withdraw {
        caller, receiver, owner: receiver, assets, shares
    });
}

#[storage(read, write)]pub fn mint(shares: u64, receiver: Identity) {
}

#[storage(read, write)]pub fn redeem(shares: u64, receiver: Identity, owner: Identity) {
}

#[storage(read)]pub fn get_total_assets() -> u64 {
    // HACK: keeping track of total assets in a storage var, pretty sure should be able to
    // get this from the native asset somehow
    temp_get_total_supply()
}

//// Internals
#[storage(read)]fn get_shares_from_assets(assets: u64) -> u64 {
    if get_total_assets() == 0 {
        assets
    } else {
        assets / get_total_assets()
    }
}

///// State management
// TODO: Remove the manual stuff once storage supported in libs
const TOTAL_SUPPLY: b256 = 0x7000000000000000000001233002723764000000000000000000000000000001;
#[storage(read)]fn temp_get_total_supply() -> u64 {
    get::<u64>(TOTAL_SUPPLY)
}
// #[storage(write)]fn temp_set_total_supply(sup: u64) {
//     store::<u64>(TOTAL_SUPPLY, sup)
// }
