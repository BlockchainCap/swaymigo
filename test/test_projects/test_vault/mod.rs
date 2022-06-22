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
async fn test_snapshots_full() {
    let (_instance, _id) = get_contract_instance().await;
}

#[tokio::test]
async fn should_fail_block_not_mined() {
    let (_instance, _id) = get_contract_instance().await;
}
