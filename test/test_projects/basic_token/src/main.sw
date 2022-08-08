contract;

use std::{address::Address, contract_id::ContractId, token::{burn, mint, transfer_to_output}};

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
        transfer_to_output(coins, asset_id, receiver)
    }
}
