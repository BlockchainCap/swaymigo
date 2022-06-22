contract;
use swaymigo::token::vault::*;
use std::{contract_id::ContractId, identity::Identity, assert::*, context::call_frames::*};

abi VaultTest {
    #[storage(read, write)]fn _deposit(receiver: Identity);
    #[storage(read, write)]fn _withdraw(receiver: Identity);
    #[storage(read)]fn _get_total_assets() -> u64;

    fn _get_asset_id() -> u64;
}
const ASSET_ID: b256 = 0x0000000000000000000000000000000000000000000000000000000000182397;
impl VaultTest for Contract {
    #[storage(read, write)]fn _deposit(receiver: Identity) {
        assert(msg_asset_id() == ~ContractId::from(ASSET_ID));
        deposit(receiver);
    }
    #[storage(read, write)]fn _withdraw(receiver: Identity) {
        // withdraw(amount, receiver, ASSET_ID);
    }
    #[storage(read)]fn _get_total_assets() -> u64 {
        get_total_assets()
    }

    fn _get_asset_id() -> u64 {
        // unique per deployment 
        return 0; // 0 is ETH
    }
}
