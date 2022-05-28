contract;
use swaypal::wrapped_asset::*;

abi WrappedToken {
    fn wrap_asset();
    fn unwrap_asset();
}

impl WrappedToken for Contract {
    fn wrap_asset() {
        wrap();
    }

    fn unwrap_asset() {
        wnwrap();
    }
}
