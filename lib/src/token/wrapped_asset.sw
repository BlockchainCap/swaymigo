library wrapped_asset;

use ::token::fungible_token::*;
use ::auth::sender::*;
use std::{identity::Identity, assert::assert, chain::auth::*, context::*, context::call_frames::*, token::*};

// need to set this per deployment
// alternative design option: have a single contract control ALL native 
// asset that are wrapped. Need some consulation w team to see if this makes any
// sense  
const ASSET_ID: b256 = 0x5670000000000000000000000000000000000000000000000000000000000123;

pub fn wrap() {
    assert(msg_asset_id().into() == ASSET_ID);
    assert(msg_amount() > 0);
    let owner = get_msg_sender_id_or_panic(msg_sender());
    mint_tokens(owner, msg_amount());
}

pub fn unwrap(amount: u64) {
    let from = get_msg_sender_id_or_panic(msg_sender());
    let balance = get_balance(from);
    // transfer the native asset, some aliasing would be nice here to make it clear 
    // this is the std libs transfer
    transfer(Identity::ContractId(contract_id()), from, amount);
    burn_tokens(from, amount);
}
