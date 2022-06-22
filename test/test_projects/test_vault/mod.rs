use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;

// Load abi from json
abigen!(
    VaultTest,
    "test_projects/test_vault/out/debug/test_vault-abi.json"
);

async fn get_contract_instance() -> (VaultTest, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_vault/out/debug/test_vault.bin",
        &wallet,
        TxParameters::default(),
    )
    .await
    .unwrap();

    let instance = VaultTest::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn test_deposit_to_vault() {
    let (_instance, _id) = get_contract_instance().await;
}

#[tokio::test]
async fn test_withdraw_from_vault() {
    let (_instance, _id) = get_contract_instance().await;
}