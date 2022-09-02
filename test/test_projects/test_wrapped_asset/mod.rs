use fuels::{prelude::*, tx::ContractId};

abigen!(
    WrappedToken,
    "test_projects/test_wrapped_asset/out/debug/test_wrapped_asset-flat-abi.json"
);

async fn get_contract_instance() -> (WrappedToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_wrapped_asset/out/debug/test_wrapped_asset.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = WrappedTokenBuilder::new(id.to_string(), wallet).build();

    (instance, id.into())
}

#[tokio::test]
async fn test_wrap_no_coins_sent_should_fail() {
    let (_instance, _id) = get_contract_instance().await;

    let wrap = _instance.wrap_asset().call().await;
    assert!(wrap.is_err());
}

// #[tokio::test]
// async fn wrap_native_assets() {
//     let (_instance, _id) = get_contract_instance().await;
//     let num_wallets = 1;
//     let coins_per_wallet = 1;
//     let amount_per_coin = 1_000_000;

//     let config = WalletsConfig::new(
//         Some(num_wallets),
//         Some(coins_per_wallet),
//         Some(amount_per_coin),
//     );
//     let wallets = launch_provider_and_get_wallets(config).await;

//     // TODO: how to send real coins?????
//     let wrap = _instance.wrap_asset().call().await;
//     assert!(!wrap.is_err());
// }
