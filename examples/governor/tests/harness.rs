use fuels::{prelude::*, tx::ContractId};

// Load abi from json
abigen!(Governor, "out/debug/governor-abi.json");

async fn get_contract_instance() -> (Governor, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy("./out/debug/governor.bin", &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = Governor::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn test_get_asset_id() {
    let (_instance, _id) = get_contract_instance().await;
    let set_asset_tx = _instance.set_vote_asset(_id).call().await;
    assert!(!set_asset_tx.is_err());
    let get_asset_tx = _instance.get_vote_asset().call().await;
    assert!(!get_asset_tx.is_err());
    assert_eq!(get_asset_tx.unwrap().value, _id);

}

