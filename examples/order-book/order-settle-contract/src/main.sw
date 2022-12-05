contract;
use std::logging::log;
use order::{LimitOrder, OrderSettler};

struct MakeOrder {
    order: LimitOrder,
}
struct TakeOrder {
    order: LimitOrder,
}

impl OrderSettler for Contract {
    fn take(order: LimitOrder) {
        log(TakeOrder { order })
    }
    fn make(order: LimitOrder) {
        log(MakeOrder { order })
    }
}
