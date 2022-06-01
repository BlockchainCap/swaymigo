library wrapped_asset;

use std::{address::Address, assert::assert, chain::auth::*, context::*, context::call_frames::*, token::*};
use ::token::fungible_token::*;
use ::auth::sender::*;

const ASSET_ID: b256 = 0x0000000000000000000000000000000000000000000000000000000000000001;
// storage {
//     asset_id: b256,
// }

// pub fn init(asset_id: b256) {
//     storage.asset_id = asset_id;
// }

pub fn wrap() {
    assert(msg_asset_id().into() == ASSET_ID);
    assert(msg_amount() > 0);
    let owner = get_msg_sender_id_or_panic(msg_sender());
    mint_tokens(owner, msg_amount());
}

pub fn unwrap(amount: u64, from: Address) {
    let balance = get_balance(from);
    // force_transfer(amount, storage.asset_id, from);
    burn_tokens(from, amount);
}
