script;
use std::token::transfer_to_address;
use std::contract_id::ContractId;
use order::{LimitOrder, OrderSettler};
// use order
fn main() {
    
}
   // unnessesary but maybe a UX or DA thing is to post an event will each order 
   // so that indexers have a picture of the order book. The predicates getting filled on chain 
   // is not enough. That is equivalent to reversing a hash.
    // let contract_address = 0xec04afe69a0ff8dc93246264540b4c65b046d902b924a26527c3705da76c0a5d;
    // let order_book = abi(OrderSettler, contract_address);
    // let order = LimitOrder {
    //     maker: Address::from(0xb1c6067c6663708d831ef3d10edf0aa4d6c14f077fc7f41f5535a30435e7cd78),
    //     maker_amount: 1_000_000_000,
    //     taker_amount: 500_000_000,
    //     maker_token: 0x0000000000000000000000000000000000000000000000000000000000000000,
    //     taker_token: 0x0000000000000000000000000000000000000000000000000000000000000000,
    //     salt: 43,
    // };
    // order_book.take(order);
