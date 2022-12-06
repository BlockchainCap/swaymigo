contract;
use swaymigo::token::vault::*;
use std::{
    address::Address,
    assert::*,
    call_frames::*,
    context::*,
    contract_id::ContractId,
    identity::Identity,
    token::*,
};

storage {
    asset_id: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000,
}

abi VaultTest {
    #[storage(read, write)]
    fn _deposit(receiver: Identity);
    #[storage(read, write)]
    fn _withdraw(receiver: Identity);
    #[storage(read, write)]
    fn simulate_vault_earning();
    #[storage(read, write)]
    fn simulate_vault_losing(amount: u64, to: ContractId);
    #[storage(write)]
    fn set_asset_id(asset_id: b256);

    #[storage(read)]
    fn _get_assets_locked() -> u64;
}
impl VaultTest for Contract {
    #[storage(read, write)]
    fn _deposit(receiver: Identity) {
        assert(msg_asset_id() == ContractId::from(storage.asset_id));
        deposit(receiver);
    }
    #[storage(read, write)]
    fn _withdraw(receiver: Identity) {
        withdraw(receiver, ContractId::from(storage.asset_id));
    }
    #[storage(read, write)]
    fn simulate_vault_earning() {
        // just receive token of type asset id
        assert(msg_asset_id() == ContractId::from(storage.asset_id));
    }
    #[storage(read, write)]
    fn simulate_vault_losing(amount: u64, to: ContractId) {
        force_transfer_to_contract(amount, ContractId::from(storage.asset_id), to);
    }

    #[storage(write)]
    fn set_asset_id(asset_id: b256) {
        storage.asset_id = asset_id
    }

    #[storage(read)]
    fn _get_assets_locked() -> u64 {
        this_balance(ContractId::from(storage.asset_id))
    }
}
