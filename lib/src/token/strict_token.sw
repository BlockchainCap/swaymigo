library strict_token;


// this is a simple token that forces all transfers to hit this smart contract by 
// only minting to predicate hash that requires 

// Not sure how to work this yet, heres my current holdups:
// - assume this contract puts all tokens behind predicates that require: 
//      1. Only coin owner can spend
//      2. All coin spending must happen via this contract
// Open Questions: 
// Predicates can't read state... how do they know who owns the coins 
// 



pub fn mint(amount: u64) {

}

pub fn transfer(amount: u64, from: Identity, to: Identity) {

}