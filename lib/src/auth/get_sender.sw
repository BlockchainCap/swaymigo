library sender;
use std::{
    identity::Identity,
    revert::revert,
    result::*,
    chain::auth::*,
    contract_id::ContractId,
};

pub fn get_msg_sender_id_or_panic(result: Result<Identity, AuthError>) -> Identity {
    match result {
        Result::Ok(s) => {
            match s {
                Identity::ContractId(v) => Identity::ContractId(v),
                Identity::Address(v) => Identity::Address(v),
                _ => revert(0),
            }
        },
        _ => {revert(0);},
    }
}