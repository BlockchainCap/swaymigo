library sender;
use std::{
    address::Address, 
    revert::revert,
    result::*,
    chain::auth::*,
    contract_id::ContractId,
};

pub fn get_msg_sender_id_or_panic(result: Result<Sender, AuthError>) -> Address {
    if let Result::Ok(s) = result {
        if let Sender::Address(v) = s {
            v
        } else {
            revert(0);
        }
    } else {
        revert(0);
    }
}
