use fuels::{prelude::*, tx::ContractId};

// Load abi from json
abigen!(
    VoteToken,
    "test_projects/test_vote_token/out/debug/test_vote_token-abi.json"
);

async fn get_contract_instance() -> (VoteToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_vote_token/out/debug/test_vote_token.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = VoteTokenBuilder::new(id.to_string(), wallet).build();

    (instance, id.into())
}

#[tokio::test]
async fn test_snapshots_full() {
    let (_instance, _id) = get_contract_instance().await;
    let receiver = LocalWallet::new_random(None).address().into();
    let garb = LocalWallet::new_random(None).address().into();

    let mint_tx = _instance._mint(receiver, 100).call().await;
    let post_mint_block = _instance.blocknumber().call().await.unwrap().value;
    let _mint_g = _instance._mint(garb, 100).call().await;
    assert!(!mint_tx.is_err());
    let mint2 = _instance._mint(receiver, 100).call().await;
    assert!(!mint2.is_err());
    let supply_snapshot = _instance
        ._get_supply_checkpoint(post_mint_block)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(supply_snapshot, 100);
    let supply_snapshot_2 = _instance
        ._get_supply_checkpoint(post_mint_block + 1)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(supply_snapshot_2, 200);

    let balance_snapshot = _instance
        ._get_voting_power(post_mint_block, receiver)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance_snapshot, 100);
    let balance_snapshot_2 = _instance
        ._get_voting_power(post_mint_block + 1, receiver)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance_snapshot_2, 100);
    let balance_snapshot_other_b4 = _instance
        ._get_voting_power(post_mint_block, garb)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance_snapshot_other_b4, 0);
    let balance_snapshot_other = _instance
        ._get_voting_power(post_mint_block + 1, garb)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance_snapshot_other, 100);
}

#[tokio::test]
async fn should_fail_block_not_mined() {
    let (_instance, _id) = get_contract_instance().await;
    let receiver = LocalWallet::new_random(None).address().into();
    let attempt_get_future_block = _instance._get_voting_power(100, receiver).call().await;
    assert!(attempt_get_future_block.is_err());
    let attempt_get_future_block_supply = _instance._get_supply_checkpoint(100).call().await;
    assert!(attempt_get_future_block_supply.is_err());
}
