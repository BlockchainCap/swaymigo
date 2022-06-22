library vault;
use std::{token::*, log::*};

struct Deposit {
    caller: Identity,
    owner: Identity,
    amount: u64,
    shares: u64
}

struct Withdraw {
    caller: Identity,
    receiver: Identity,
    owner: Identity,
    amount: u64,
    shares: u64
}

#[storage(read, write)]
pub fn deposit(amount: u64, receiver: Identity) {

}

#[storage(read, write)]
pub fn withdraw(amount: u64, reciever: Identity) {

}


#[storage(read)]
pub fn get_total_assets() -> u64 {

}





///// State management stuff
// TODO: Remove the manual stuff once storage supported in libs

