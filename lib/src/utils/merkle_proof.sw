library merkle_proof;
// use std::hash::sha256;

// /// Verify inclusion of a leaf in a merkle tree
// /// TODO: Vec currently not supported, need a dynamically sized array for this
// pub fn verify(proof: TempByteVec, root: b256, leaf: b256) -> bool {
//     // TODO: dynamically sized b256 array doesnt work
//     // TODO: there are no for loops

//     let proof_length = proof.length;
//     let mut i = 0;
//     let leaf_hash = sha256(leaf);
//     let mut hash_agg = leaf_hash;
//     while i < proof_length {
//         // need to index the actual proof Vec, this obv does nothing currently
//         hash_agg = sha256((leaf_hash, proof.get));
//         i = i + 1;
//     }
//     return hash_agg == root;
//     false
// }

// // will replace with Vec<b256> when available
// struct TempByteVec {
//     get: b256,
//     length: u64
// }
