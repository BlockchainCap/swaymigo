contract;
use swaymigo::token::wrapped_asset::*;

abi WrappedToken {
    #[storage(read, write)]fn wrap_asset();
    #[storage(read, write)]fn unwrap_asset(amount: u64);
}

impl WrappedToken for Contract {
    #[storage(read, write)]fn wrap_asset() {
        wrap();
    }

    #[storage(read, write)]fn unwrap_asset(amount: u64) {
        unwrap(amount);
    }
}
