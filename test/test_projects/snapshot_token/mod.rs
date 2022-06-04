use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;

// Load abi from json
abigen!(SnapshotToken, "test_projects/snapshot_token/out/debug/snapshot_token-abi.json");

async fn get_contract_instance() -> (SnapshotToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy("test_projects/snapshot_token/out/debug/snapshot_token-abi.json", &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = SnapshotToken::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn test_mint_tokens() {
    let (_instance, _id) = get_contract_instance().await;
}