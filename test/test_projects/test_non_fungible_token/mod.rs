use fuels::tx::Address;
use fuels::{prelude::*, tx::ContractId};
use std::str::FromStr;

// Load abi from json
abigen!(
    TestNFT,
    "test_projects/test_non_fungible_token/out/debug/test_non_fungible_token-abi.json"
);

async fn get_contract_instance() -> (TestNFT, ContractId, WalletUnlocked) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_non_fungible_token/out/debug/test_non_fungible_token.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = TestNFT::new(id.clone(), wallet.clone());

    (instance, ContractId::from(id), wallet)
}

#[tokio::test]
async fn can_mint() {
    let (_instance, _id, _) = get_contract_instance().await;
    let address = WalletUnlocked::new_random(None).address().into();
    let mint_res = _instance
        .methods()
        ._mint(Identity::Address(address), 1)
        .call()
        .await;
    assert!(!mint_res.is_err());

    let supply = _instance.methods()._supply().call().await.unwrap().value;
    assert_eq!(supply, 1);
    let balance = _instance
        .methods()
        ._balance_of(Identity::Address(address))
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance, 1);
    let owner = _instance.methods()._owner_of(1).call().await.unwrap().value;
    let address_identity = Identity::Address(address);
    assert_eq!(owner, address_identity);
}

#[tokio::test]
async fn can_burn() {
    let (_instance, _id, _) = get_contract_instance().await;
    let address = WalletUnlocked::new_random(None).address().into();
    let mint_res = _instance
        .methods()
        ._mint(Identity::Address(address), 12)
        .call()
        .await;
    assert!(!mint_res.is_err());

    let burn_res = _instance
        .methods()
        ._burn(Identity::Address(address), 12)
        .call()
        .await;
    assert!(!burn_res.is_err());

    let supply = _instance.methods()._supply().call().await.unwrap().value;
    assert_eq!(supply, 0);
    let balance = _instance
        .methods()
        ._balance_of(Identity::Address(address))
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance, 0);
    let owner = _instance
        .methods()
        ._owner_of(12)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(
        owner,
        Identity::Address(
            Address::from_str("0x0000000000000000000000000000000000000000000000000000000000000000")
                .unwrap()
        )
    );
}

#[tokio::test]
async fn can_transfer() {
    let (_instance, _id, wallet) = get_contract_instance().await;
    let address2 = WalletUnlocked::new_random(None).address().into();
    let mint_res = _instance
        .methods()
        ._mint(Identity::Address(wallet.address().into()), 12)
        .call()
        .await;
    assert!(!mint_res.is_err());

    let transfer = _instance
        .methods()
        ._transfer(
            Identity::Address(wallet.address().into()),
            Identity::Address(address2),
            12,
        )
        .call()
        .await;
    assert!(!transfer.is_err());

    let supply = _instance.methods()._supply().call().await.unwrap().value;
    assert_eq!(supply, 1);
    let balance = _instance
        .methods()
        ._balance_of(Identity::Address(wallet.address().into()))
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance, 0);
    let balance2 = _instance
        .methods()
        ._balance_of(Identity::Address(address2))
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(balance2, 1);
    let owner = _instance
        .methods()
        ._owner_of(12)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(owner, Identity::Address(address2));
}
