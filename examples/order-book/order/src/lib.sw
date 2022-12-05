library order;
abi OrderSettler {
    fn take(order: LimitOrder);
    fn make(order: LimitOrder);
}
// pub enum Order {
//     Limit: LimitOrder,
//     RFQ: RFQOrder,
//     NFT: NFTOrder,
// }
// inspired by the 0x limit order 
pub struct LimitOrder {
    maker_token: b256, // using b256 for convenience, may be a bad idea. 
    taker_token: b256,
    maker_amount: u64,
    taker_amount: u64,
    // taker_token_fee: u64,
    maker: Address,
    // taker: Address,
    // sender: Address,
    // fee_recipient: Address,
    // pool:  
    // expiry: u64,
    salt: u64, // arbitrary salt for uniqueness in order hash
}

//// NOT USING THESE YET 
pub struct RFQOrder {
    maker_token: Address,
    taker_token: Address,
    maker_amount: u64,
    taker_amount: u64,
    taker_token_fee: u64,
    maker: Address,
    taker: Address,
    // pool:  
    expiry: u64,
    salt: u64, // arbitrary salt for uniqueness in order hash
}

// not sure how we do this without accessing some state
pub struct NFTOrder {
    direction: bool, // could be enum if cleaner
    maker: Address,
    taker: Address,
    expiry: u64,
    nonce: u64,
    fungible_token: Address,
    fungible_token_amount: u64,
    // fees
    nft_token: Address,
    nft_id: Address,
}
