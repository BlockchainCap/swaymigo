use fuels::{prelude::*, tx::{ContractId, AssetId}};
use fuels_abigen_macro::abigen;

abigen!(
    VaultTest,
    "test_projects/test_vault/out/debug/test_vault-abi.json"
);
abigen!(
    BasicToken,
    "test_projects/basic_token/out/debug/basic_token-abi.json"
);

async fn get_vault_instance() -> (VaultTest, ContractId) {
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

async fn get_basic_token_instance() -> (BasicToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy(
        "test_projects/basic_token/out/debug/basic_token.bin",
        &wallet,
        TxParameters::default(),
    )
    .await
    .unwrap();

    let instance = BasicToken::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn test_deposit_to_vault() {
    let (_token_instance, _asset_id) = get_basic_token_instance().await;
    let (_instance, _id) = get_vault_instance().await;
    let set_res = _instance.set_asset_id(_asset_id.into()).call().await;
    assert!(!set_res.is_err());
    // mint arbitrary amount to the test wallet 
    let receiver = LocalWallet::new_random(None).address();
    let _mint_tx = _token_instance.mint(10000).call().await;
    let _transfer_tx = _token_instance.force_transfer(100, _asset_id, receiver);

    let deposit_tx = _instance._deposit(receiver)
            .call_params(CallParameters::new(Some(10), Some(AssetId::from(*_asset_id.clone()))))
            .call()
            .await;
    println!("{:?}", deposit_tx);
    assert!(!deposit_tx.is_err());

}

#[tokio::test]
async fn test_withdraw_from_vault() {
    let (_instance, _id) = get_vault_instance().await;
}
