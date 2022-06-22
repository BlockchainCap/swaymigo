contract;
use swaymigo::token::vault::*;
use std::{assert::*, context::call_frames::*, address::Address, contract_id::ContractId, identity::Identity, token::*};

storage {
    asset_id: b256,
}

const NULL_ADDY: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;

abi VaultTest {
    #[storage(read, write)]fn _deposit(receiver: Address);
    #[storage(read, write)]fn _withdraw(receiver: Address);
    #[storage(read, write)]fn simulate_vault_earning();
    #[storage(read, write)]fn simulate_vault_losing(amount: u64);
    #[storage(write)]fn set_asset_id(asset_id: b256);
}
impl VaultTest for Contract {
    #[storage(read, write)]fn _deposit(receiver: Address) {
        assert(msg_asset_id() == ~ContractId::from(storage.asset_id));
        deposit(Identity::Address(receiver));
    }
    #[storage(read, write)]fn _withdraw(receiver: Address) {
        withdraw(Identity::Address(receiver), contract_id());
    }
    #[storage(read, write)]fn simulate_vault_earning() {
        // just receive token of type asset id
        assert(msg_asset_id() == ~ContractId::from(storage.asset_id));
    }
    #[storage(read, write)]fn simulate_vault_losing(amount: u64) {
        force_transfer_to_contract(amount, ~ContractId::from(storage.asset_id), ~ContractId::from(NULL_ADDY))
    }

    #[storage(write)]fn set_asset_id(asset_id: b256) {
        storage.asset_id = asset_id
    }
}
