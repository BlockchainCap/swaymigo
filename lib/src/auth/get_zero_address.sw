library zero_address;
use std::{address::Address, identity::Identity};

pub fn get_zero_address() -> Identity {
    Identity::Address(Address::from(0x0000000000000000000000000000000000000000000000000000000000000000))
}