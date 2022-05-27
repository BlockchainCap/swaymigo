library wrapped_asset;
use std::{auth::*, context::*, contract::*};
use ::fungible_token::*;

// update this per deployment
// maybe easier if its in storage
const ASSET_ID: b256 = 0xDEADBEEF00000000000000000000000000000000000000000000000000000000;

pub fn wrap() {
    // make sure the coins being sent here match the asset ID
    let asset_id = msg_asset_id();
    // make sure the owner stuff is correct

    // do the underlying accounting

    if let Sender::Address(coins_owner) = get_coins_owner() {
        let amount = msg_amount();
        mint_tokens(amount, coins_owner);
    } else {
        revert();
    }
}

pub fn unwrap(amount: u64) {
    // all the check and shit

    // how to transfer the assets to the sender

    // update accounting
    burn_tokens(amount);
}
