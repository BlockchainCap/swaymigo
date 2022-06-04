use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;

// Load abi from json
abigen!(
    VoteToken,
    "test_projects/test_vote_token/out/debug/test_vote_token-abi.json"
);

async fn get_contract_instance() -> (VoteToken, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_vote_token/out/debug/test_vote_token.bin",
        &wallet,
        TxParameters::default(),
    )
    .await
    .unwrap();

    let instance = VoteToken::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn test_supply_snapshots() {
    let (_instance, _id) = get_contract_instance().await;
    let receiver = LocalWallet::new_random(None).address();
    // let garb = LocalWallet::new_random(None).address();

    let mint_tx = _instance._mint(receiver, 100).call().await;
    // let mint_g = _instance._mint(garb, 100).call().await;
    assert!(!mint_tx.is_err());

    let post_mint_block = _instance.blocknumber().call().await.unwrap().value;
    println!("{:?}", post_mint_block);

    let mint2 = _instance._mint(receiver, 100).call().await;
    assert!(!mint2.is_err());

    let supply_snapshot = _instance
        ._get_supply_checkpoint(post_mint_block)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(supply_snapshot, 100);
    // let balance_snapshot = _instance
    //     ._get_voting_power(post_mint_block, receiver)
    //     .call()
    //     .await
    //     .unwrap()
    //     .value;
    // assert_eq!(balance_snapshot, 100);
}


#[tokio::test]
async fn should_fail_block_not_mined() {

}