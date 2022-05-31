library wrapped_asset;

use std::{chain::auth::*, context::msg_amount, assert::assert, token::*};
use ::token::fungible_token::*;

storage {
    asset_id: b256,
}

pub fn init(asset_id: b256) {
    storage.asset_id = asset_id;
}

pub fn wrap() { // make sure the coins being sent here match the asset ID let asset_id = msg_asset_id();
    assert(msg_asset_id() == storage.asset_id);
    assert(msg_amount() > 0);
    let owner = get_coins_owner();
    mint_tokens(owner, msg_amount());
}

pub fn unwrap(amount: u64, from: Address) {
    let balance = get_balance(owner)
    force_transfer(amount, storage.asset_id, from);
    burn_tokens(from, amount);
}
