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
async fn test_vault_e2e() {
    let (_token_instance, token_contract, wallet) = get_basic_token_instance().await;
    // let provider = wallet.get_provider().unwrap().clone();
    let asset_id = AssetId::from(*token_contract.clone());
    let (vault_instance, vault_contract_id) = get_vault_instance(wallet.clone()).await;
    let shares_asset_id = AssetId::from(*vault_contract_id.clone());
    let set_res = vault_instance.set_asset_id(asset_id.into()).call().await;
    assert!(!set_res.is_err());
    let _mint_tx = _token_instance.mint(10_000).call().await;
    let _transfer_tx = _token_instance
        .force_transfer(100, token_contract, wallet.address())
        .append_variable_outputs(1)
        .call()
        .await;
    let deposit_tx = vault_instance
        ._deposit(wallet.address())
        .call_params(CallParameters::new(Some(10), Some(asset_id)))
        .append_variable_outputs(1)
        .call()
        .await;
    assert!(!deposit_tx.is_err());

    // check the balance of the share token, should be exactly the same as deposited
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 10);
    assert_eq!(asset_balance, 90);
    // this is simulating if the vault gained more underlying asset without anyone depositing into the pool
    let sim_interest = vault_instance
        .simulate_vault_earning()
        .call_params(CallParameters::new(Some(10), Some(asset_id)))
        .call()
        .await;
    assert!(!sim_interest.is_err());
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 10);
    assert_eq!(asset_balance, 80);
    // TODO: having difficulty checking the asset balances of a contract via fuels-rs.
    // Enshrining this on the contact feels like a hack.
    let assets_locked = vault_instance
        ._get_assets_locked()
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(assets_locked, 20);
    let withdraw_tx = vault_instance
        ._withdraw(wallet.address())
        .call_params(CallParameters::new(Some(5), Some(shares_asset_id)))
        .append_variable_outputs(1)
        .call()
        .await;
    println!("{:?}", withdraw_tx);
    assert!(!withdraw_tx.is_err());
    println!("{:?}", withdraw_tx.unwrap().logs);
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 5);
    assert_eq!(asset_balance, 90);
    // TODO: having difficulty checking the asset balances of a contract via fuels-rs.
    // Enshrining this on the contact feels like a hack.
    let assets_locked = vault_instance
        ._get_assets_locked()
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(assets_locked, 10);
}

#[tokio::test]
async fn test_withdraw_from_vault() {}
