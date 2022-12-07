use fuels::{prelude::*, tx::ContractId};

// Load abi from json
abigen!(
    MerkleProofTestContract,
    "test_projects/test_merkle_proof/out/debug/test_merkle_proof-abi.json"
);

async fn get_contract_instance() -> (MerkleProofTestContract, ContractId) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;

    let id = Contract::deploy(
        "test_projects/test_merkle_proof/out/debug/test_merkle_proof.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = MerkleProofTestContract::new(id.clone(), wallet);

    (instance, ContractId::from(id))
}

#[tokio::test]
async fn verify_correct_merkle_proof() {
    let (_instance, _id) = get_contract_instance().await;
    // let addr1 = WalletUnlocked::new_random(None).address();
    // let addr2 = WalletUnlocked::new_random(None).address();
    // let address1 = [
    //     118, 64, 238, 245, 229, 5, 191, 187, 201, 174, 141, 75, 72, 119, 88, 252, 38, 62, 110, 176,
    //     51, 16, 126, 190, 233, 136, 54, 127, 90, 101, 230, 168,
    // ];
    // let address2 = [
    //     8, 4, 28, 217, 200, 5, 161, 17, 20, 214, 54, 77, 72, 118, 90, 31, 225, 63, 110, 77, 190,
    //     190, 12, 1, 233, 48, 54, 72, 90, 253, 100, 103,
    // ];

    // // let expected_1 = hash_b256(address1, Hash::Sha256);
    // let hash_addr1 = Sha256::digest(address1).into();
    // let hash_addr2 = Sha256::digest(address2).into();
    // let hash_both = Sha256::digest((address1, address2)).into();
    // // let expected_2 = hash_b256(address2, Hash::Sha256);
    // let proof: Vec<[u8; 32]> = vec![];
    // let root: [u8; 32] = hash_both;
    // let leaf: [u8; 32] = address1;
    // let result = _instance
    //     .verify_proof(proof, root, leaf)
    //     .call()
    //     .await
    //     .unwrap()
    //     .value;
    // assert_eq!(result, true)
}

// #[tokio::test]
// async fn bad_merkle_proof_fails() {
//     let (_instance, _id) = get_contract_instance().await;
//     let proof;
//     let root;
//     let leaf;
//     let result = _instance
//         .verify_proof(proof, root, leaf)
//         .call()
//         .await
//         .unwrap()
//         .value;
//     assert_eq!(result, true)
// }
