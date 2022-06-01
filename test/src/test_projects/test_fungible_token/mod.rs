use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;

// Load abi from json
abigen!(TestToken, "test_fungible_token/out/debug/test_fungible_token-abi.json");

async fn get_contract_instance() -> (TestToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy("./out/debug/test_fungible_token.bin", &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = TestToken::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn can_get_contract_id() {
    let (_instance, _id) = get_contract_instance().await;

    // Now you have an instance of your contract you can use to test each function
}
