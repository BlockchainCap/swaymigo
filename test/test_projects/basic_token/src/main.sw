contract;

use std::{
    address::Address,
    contract_id::ContractId,
    identity::Identity,
    token::{
        burn,
        mint,
        transfer,
    },
};

abi BasicToken {
    fn mint(mint_amount: u64);
    fn burn(burn_amount: u64);
    fn force_transfer(coins: u64, asset_id: ContractId, receiver: Address);
}
impl BasicToken for Contract {
    fn mint(mint_amount: u64) {
        mint(mint_amount);
    }

    fn burn(burn_amount: u64) {
        burn(burn_amount);
    }

    fn force_transfer(coins: u64, asset_id: ContractId, receiver: Address) {
        transfer(coins, asset_id, Identity::Address(receiver))
    }
}
