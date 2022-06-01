library zero_address;
use std::address::Address;

pub fn get_zero_address() -> Address {
    ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000)
}
