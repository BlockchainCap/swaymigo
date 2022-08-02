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
async fn create_proposal() {
    let (_instance, _id) = get_contract_instance().await;
    let wallet = LocalWallet::new_random(None);
    let mint_tx = _instance.mint_a(wallet.address(), 100);


}
