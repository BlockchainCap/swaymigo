contract;
use swaymigo::token::vault::*;
use std::{contract_id::ContractId, identity::Identity};

abi VaultTest {
    #[storage(read, write)]fn _deposit(amount: u64, receiver: Identity);
    #[storage(read, write)]fn _withdraw(amount: u64, receiver: Identity);
    #[storage(read)]fn _get_total_assets() -> u64;

    fn _get_asset_id() -> u64;
}
// const ASSET_ID: ContractId = ~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000182397);
impl VaultTest for Contract {
    #[storage(read, write)]fn _deposit(amount: u64, receiver: Identity) {
        deposit(amount, receiver);
    }
    #[storage(read, write)]fn _withdraw(amount: u64, receiver: Identity) {
        // withdraw(amount, receiver, ASSET_ID);
    }
    #[storage(read)]fn _get_total_assets() -> u64 {
        get_total_assets()
    }

    fn _get_asset_id() -> u64 {
        // unique per implementation
        return 0; // 0 is ETH
    }
}
