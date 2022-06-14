library zero_address;
use std::{identity::Identity, address::Address};

pub fn get_zero_address() -> Identity {
    Identity::Address(~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000))
}
