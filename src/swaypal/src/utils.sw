library utils;
use std::address::Address;
pub fn ZERO_ADDRESS() -> Address {
    ~Address::from(0x0000000000000000000000000000000000000000000000000000000000000000);
}