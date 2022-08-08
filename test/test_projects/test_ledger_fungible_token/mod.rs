use fuels::{prelude::*, tx::ContractId};

// Load abi from json
abigen!(
    TestToken,
    "test_projects/test_ledger_fungible_token/out/debug/test_ledger_fungible_token-abi.json"
);

async fn get_contract_instance() -> (TestToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_ledger_fungible_token/out/debug/test_ledger_fungible_token.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = TestTokenBuilder::new(id.to_string(), wallet).build();

    (instance, id.into())
}

#[tokio::test]
async fn test_mint_tokens() {
    let (_instance, _id) = get_contract_instance().await;
    let receiver = LocalWallet::new_random(None).address().into();

    let mint_res = _instance.mint(receiver, 100).call().await;
    assert!(!mint_res.is_err());
    let balance_rec = _instance.balance_of(receiver).call().await.unwrap().value;
    assert_eq!(balance_rec, 100);
    let supply = _instance.get_supply().call().await.unwrap().value;
    assert_eq!(supply, 100);
}

#[tokio::test]
async fn test_burn_tokens() {
    let (_instance, _id) = get_contract_instance().await;
    let receiver = LocalWallet::new_random(None).address().into();
    let mint_res = _instance.mint(receiver, 100).call().await;
    assert!(!mint_res.is_err());
    // now burn
    let burn_res = _instance.burn(receiver, 30).call().await;
    assert!(!burn_res.is_err());
    let new_balance = _instance.balance_of(receiver).call().await.unwrap().value;
    assert_eq!(new_balance, 70);
    let supply = _instance.get_supply().call().await.unwrap().value;
    assert_eq!(supply, 70);
}

#[tokio::test]
async fn test_transfer_tokens() {
    let (_instance, _id) = get_contract_instance().await;
    let from = LocalWallet::new_random(None).address().into();
    let to = LocalWallet::new_random(None).address().into();
    let mint_res = _instance.mint(from, 100).call().await;

    assert!(!mint_res.is_err());
    let transfer_tx = _instance.transfer_tokens(from, to, 20).call().await;

    assert!(!transfer_tx.is_err());
    let from_balance = _instance.balance_of(from).call().await.unwrap().value;
    let to_balance = _instance.balance_of(to).call().await.unwrap().value;
    assert_eq!(from_balance, 80);
    assert_eq!(to_balance, 20);
    let supply = _instance.get_supply().call().await.unwrap().value;
    assert_eq!(supply, 100);
}
