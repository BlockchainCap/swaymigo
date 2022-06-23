use fuels::{
    prelude::*,
    signers::wallet::Wallet,
    tx::{AssetId, ContractId},
};
use fuels_abigen_macro::abigen;

abigen!(
    VaultTest,
    "test_projects/test_vault/out/debug/test_vault-abi.json"
);
abigen!(
    BasicToken,
    "test_projects/basic_token/out/debug/basic_token-abi.json"
);

async fn get_vault_instance(wallet: Wallet) -> (VaultTest, ContractId) {
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

async fn get_basic_token_instance() -> (BasicToken, ContractId, Wallet) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;
    let wallet_clone = wallet.clone();
    let id = Contract::deploy(
        "test_projects/basic_token/out/debug/basic_token.bin",
        &wallet,
        TxParameters::default(),
    )
    .await
    .unwrap();

    let instance = BasicToken::new(id.to_string(), wallet);

    (instance, id, wallet_clone)
}

#[tokio::test]
async fn test_deposit_to_vault() {
    let (_token_instance, token_contract, wallet) = get_basic_token_instance().await;
    let asset_id = AssetId::from(*token_contract.clone());
    let (_instance, _id) = get_vault_instance(wallet.clone()).await;
    let set_res = _instance.set_asset_id(asset_id.into()).call().await;
    assert!(!set_res.is_err());
    let _mint_tx = _token_instance.mint(10_000).call().await;
    let _transfer_tx = _token_instance
        .force_transfer(100, token_contract, wallet.address())
        .append_variable_outputs(2)
        .call()
        .await;
    let receiver_vault = VaultTest::new(_id.to_string(), wallet.clone());
    let deposit_tx = receiver_vault
        ._deposit(wallet.address())
        .call_params(CallParameters::new(Some(10), Some(asset_id)))
        .append_variable_outputs(2)
        .call()
        .await;
    println!("{:?}", deposit_tx);
    assert!(!deposit_tx.is_err());
}

#[tokio::test]
async fn test_withdraw_from_vault() {
    // let (_instance, _id) = get_vault_instance().await;
}
