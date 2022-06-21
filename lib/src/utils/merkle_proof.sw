library merkle_proof;
use std::{hash::sha256, vec::Vec};

/// Verify inclusion of a leaf in a merkle tree
pub fn verify(proof: Vec<b256>, root: b256, leaf: b256) -> bool {
    let proof_length = proof.len;
    let mut i = 0;
    let leaf_hash = sha256(leaf);
    let mut hash_agg = leaf_hash;
    while i < proof_length {
        hash_agg = sha256((leaf_hash, proof.get(i)));
        i = i + 1;
    }
    return hash_agg == root;
    false
}
