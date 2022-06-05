contract;
use swaymigo::token::wrapped_asset::*;

abi WrappedToken {
    fn wrap_asset();
    fn unwrap_asset(amount: u64);
}

impl WrappedToken for Contract {
    fn wrap_asset() {
        wrap();
    }

    fn unwrap_asset(amount: u64) {
        unwrap(amount);
    }
}
