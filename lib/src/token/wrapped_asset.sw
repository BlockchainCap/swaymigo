library wrapped_asset;

use ::token::fungible_token::*;
use ::auth::sender::*;
use std::{address::Address, assert::assert, chain::auth::*, context::*, context::call_frames::*, token::*};

// need to set this per deployment 
const ASSET_ID: b256 = 0x0000000000000000000000000000000000000000000000000000000000000001;

pub fn wrap() {
    assert(msg_asset_id().into() == ASSET_ID);
    assert(msg_amount() > 0);
    let owner = get_msg_sender_id_or_panic(msg_sender());
    mint_tokens(owner, msg_amount());
}

pub fn unwrap(amount: u64, from: Address) {
    let balance = get_balance(from);
    transfer(~Address::from(contract_id().into()), from, amount);
    burn_tokens(from, amount);
}
