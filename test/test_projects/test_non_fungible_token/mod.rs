use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;

// Load abi from json
abigen!(TestNFT, "test_projects/test_non_fungible_token/out/debug/test_non_fungible_token-abi.json");

async fn get_contract_instance() -> (TestNFT, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy("test_projects/test_non_fungible_token/out/debug/test_non_fungible_token.bin", &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = TestNFT::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn can_get_contract_id() {
    let (_instance, _id) = get_contract_instance().await;

    // Now you have an instance of your contract you can use to test each function
}
