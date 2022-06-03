use fuels::{prelude::*, tx::ContractId};
use fuels_abigen_macro::abigen;
use fuels::tx::Address;
use std::str::FromStr;


// Load abi from json
abigen!(TestNFT, "test_projects/test_non_fungible_token/out/debug/test_non_fungible_token-abi.json");

async fn get_contract_instance() -> (TestNFT, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_single_wallet().await;

    let id = Contract::deploy("test_projects/test_non_fungible_token/out/debug/test_non_fungible_token.bin", &wallet, TxParameters::default())
        .await
        .unwrap();

    let instance = TestNFT::new(id.to_string(), wallet);

    (instance, id)
}

#[tokio::test]
async fn can_mint() {
    let (_instance, _id) = get_contract_instance().await;
    let address = LocalWallet::new_random(None).address();
    let mint_res = _instance._mint(address, 1).call().await;
    assert!(!mint_res.is_err());

    let supply = _instance._supply().call().await.unwrap().value;
    assert_eq!(supply, 1);
    let balance = _instance._balance_of(address).call().await.unwrap().value;
    assert_eq!(balance, 1);
    let owner = _instance._owner_of(1).call().await.unwrap().value;
    assert_eq!(owner, address);
}

#[tokio::test]
async fn can_burn() {
    let (_instance, _id) = get_contract_instance().await;
    let address = LocalWallet::new_random(None).address();
    let mint_res = _instance._mint(address, 12).call().await;
    assert!(!mint_res.is_err());
    
    let burn_res = _instance._burn(address, 12).call().await;
    assert!(!burn_res.is_err());

    let supply = _instance._supply().call().await.unwrap().value;
    assert_eq!(supply, 0);
    let balance = _instance._balance_of(address).call().await.unwrap().value;
    assert_eq!(balance, 0);
    let owner = _instance._owner_of(12).call().await.unwrap().value;
    assert_eq!(owner, Address::from_str("0x0000000000000000000000000000000000000000000000000000000000000000").unwrap());
}


#[tokio::test]
async fn can_transfer() {
    let (_instance, _id) = get_contract_instance().await;
    let address = LocalWallet::new_random(None).address();
    let address2 = LocalWallet::new_random(None).address();
    let mint_res = _instance._mint(address, 12).call().await;
    assert!(!mint_res.is_err());
    
    let transfer = _instance._transfer(address, address2, 12).call().await;
    assert!(!transfer.is_err());

    let supply = _instance._supply().call().await.unwrap().value;
    assert_eq!(supply, 1);
    let balance = _instance._balance_of(address).call().await.unwrap().value;
    assert_eq!(balance, 0);
    let balance2 = _instance._balance_of(address2).call().await.unwrap().value;
    assert_eq!(balance2, 1);
    let owner = _instance._owner_of(12).call().await.unwrap().value;
    assert_eq!(owner, address2);
}