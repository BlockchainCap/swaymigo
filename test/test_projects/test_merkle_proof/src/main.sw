contract;
use swaymigo::utils::merkle_proof::*;
use std::vec::*;

abi MerkleProofTestContract {
    fn verify_proof(proof: Vec<b256>, root: b256, leaf: b256) -> bool;
}

impl MerkleProofTestContract for Contract {
    fn verify_proof(proof: Vec<b256>, root: b256, leaf: b256) -> bool {
        verify(proof, root, leaf)
    }
}