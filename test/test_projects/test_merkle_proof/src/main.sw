contract;

use swaypal::utils::merkle_proof::*;

abi MyContract {
    fn verify_proof() -> bool;
}

impl MyContract for Contract {
    fn verify_proof() -> bool {
        // proof is an array of hashes
        // let proof: Vec<b256> = [];

        // let leaf: b256 = 0x0000000000000000000000000000000000000000000000000000000000000012;
        // let root: b256 = 0x0000000000000000000000000000000000000000000000000000000000000123;
        // verify(prood, root, leaf);
        false
    }
}
