contract;

// use swaymigo::utils::merkle_proof::*;

abi MerkleProofTestContract {
    // TODO For now, Vec<T> does not work in storage nor in the ABI (contract method arguments and returns).
    // fn verify_proof(proof: Vec<b256>, root: b256, leaf: b256) -> bool;
    fn verify_proof() -> bool;
}

impl MerkleProofTestContract for Contract {
    // fn verify_proof(proof: Vec<b256>, root: b256, leaf: b256) -> bool {
    //     verify(proof, root, leaf)
    // }
    fn verify_proof() -> bool {
        false
    }
}
