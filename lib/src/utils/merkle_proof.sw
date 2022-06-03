library merkle_proof;
// use std::hash::sha256;

/// Verify inclusion of a leaf in a merkle tree
/// TODO: Vec currently not supported, need a dynamically sized array for this
// pub fn verify(proof: Vec<b256>, root: b256, leaf: b256) -> bool {
//     // TODO: dynamically sized b256 array doesnt work
//     // TODO: there are no for loops

//     let proof_length = proof.length;
//     let mut i = 0;
//     let leaf_hash = sha256(leaf);
//     let mut hash_agg = leaf_hash;
//     while i < proof_length {
//         hash_agg = sha256((leaf_hash, proof[i]));
//         i = i + 1;
//     }
//     return hash_agg == root;
// }