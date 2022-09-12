use fuels::{
    prelude::*,
    tx::{AssetId, ContractId},
};

abigen!(
    VaultTest,
    "test_projects/test_vault/out/debug/test_vault-abi.json"
);
abigen!(
    BasicToken,
    "test_projects/basic_token/out/debug/basic_token-abi.json"
);

async fn get_vault_instance(wallet: WalletUnlocked) -> (VaultTest, ContractId) {
    let id = Contract::deploy(
        "test_projects/test_vault/out/debug/test_vault.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = VaultTestBuilder::new(id.to_string(), wallet).build();

    (instance, id.into())
}

async fn get_basic_token_instance() -> (BasicToken, ContractId, WalletUnlocked) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;
    let wallet_clone = wallet.clone();
    let id = Contract::deploy(
        "test_projects/basic_token/out/debug/basic_token.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = BasicTokenBuilder::new(id.to_string(), wallet).build();

    (instance, id.into(), wallet_clone)
}

#[tokio::test]
async fn test_vault_e2e() {
    let (_token_instance, token_contract, wallet) = get_basic_token_instance().await;
    let asset_id = AssetId::from(*token_contract.clone());
    let (vault_instance, vault_contract_id) = get_vault_instance(wallet.clone()).await;
    let shares_asset_id = AssetId::from(*vault_contract_id.clone());
    vault_instance
        .set_asset_id(asset_id.into())
        .call()
        .await
        .unwrap();
    let _mint_tx = _token_instance.mint(10_000_000).call().await.unwrap();
    let _transfer_tx = _token_instance
        .force_transfer(5_000_000, token_contract.into(), wallet.address().into())
        .append_variable_outputs(1)
        .call()
        .await
        .unwrap();
    let balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(5_000_000, balance);
    vault_instance
        ._deposit(vaulttest_mod::Identity::Address(wallet.address().into()))
        .call_params(CallParameters::new(Some(2_000_000), Some(asset_id), None))
        .append_variable_outputs(1)
        .call()
        .await
        .unwrap();
    // check the balance of the share token, should be exactly the same as deposited
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 2_000_000);
    assert_eq!(asset_balance, 3_000_000);
    // this is simulating if the vault gained more underlying asset without anyone depositing into the pool
    vault_instance
        .simulate_vault_earning()
        .call_params(CallParameters::new(Some(1_000_000), Some(asset_id), None))
        .call()
        .await
        .unwrap();
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 2_000_000);
    assert_eq!(asset_balance, 2_000_000);
    // TODO: having difficulty checking the asset balances of a contract via fuels-rs.
    // Enshrining this on the contact feels like a hack.
    let assets_locked = vault_instance
        ._get_assets_locked()
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(assets_locked, 3_000_000);
    vault_instance
        ._withdraw(vaulttest_mod::Identity::Address(wallet.address().into()))
        .call_params(CallParameters::new(
            Some(500_000),
            Some(shares_asset_id),
            None,
        ))
        .append_variable_outputs(1)
        .call()
        .await
        .unwrap();
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 1_500_000);
    assert_eq!(asset_balance, 2_500_000);
    // TODO: having difficulty checking the asset balances of a contract via fuels-rs.
    // Enshrining this on the contact feels like a hack.
    let assets_locked = vault_instance
        ._get_assets_locked()
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(assets_locked, 2_500_000);
    // sim just burns tokens to the other contract
    let _sim_loss = vault_instance
        .simulate_vault_losing(500_000, token_contract)
        .set_contracts(&[token_contract.into()])
        .append_variable_outputs(1)
        .call()
        .await
        .unwrap();
    let assets_locked = vault_instance
        ._get_assets_locked()
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(assets_locked, 2_000_000);
    let _withdraw_tx = vault_instance
        ._withdraw(vaulttest_mod::Identity::Address(wallet.address().into()))
        .call_params(CallParameters::new(
            Some(500_000),
            Some(shares_asset_id),
            None,
        ))
        .append_variable_outputs(1)
        .call()
        .await
        .unwrap();
    let shares_balance = wallet.get_asset_balance(&shares_asset_id).await.unwrap();
    let asset_balance = wallet.get_asset_balance(&asset_id).await.unwrap();
    assert_eq!(shares_balance, 1000000);
    assert_eq!(asset_balance, 3000000);
    let assets_locked = vault_instance
        ._get_assets_locked()
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(assets_locked, 1500000);
}

#[tokio::test]
async fn test_withdraw_from_vault() {}
