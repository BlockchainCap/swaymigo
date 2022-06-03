use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;

// Load abi from json
abigen!(WrappedToken, "test_projects/test_wrapped_asset/out/debug/test_wrapped_asset-abi.json");

async fn get_contract_instance() -> (WrappedToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy("test_projects/test_wrapped_asset/out/debug/test_wrapped_asset.bin", &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = WrappedToken::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn test_wrap_no_coins_sent_should_fail() {
    let (_instance, _id) = get_contract_instance().await;

    let wrap = _instance.wrap_asset().call().await;
    assert!(wrap.is_err());
}


#[tokio::test]
async fn wrap_native_assets() {
    let (_instance, _id) = get_contract_instance().await;

    // TODO: how to send real coins?????
    let wrap = _instance.wrap_asset().call().await;
    assert!(!wrap.is_err());
}