contract;
use swaypal::wrapped_asset::*;

abi Token {
    fn test_function() -> bool;
    fn wrap();
    fn unwrap();
}

impl Token for WrappedAsset {
    fn wrap() {

    }

    fn unwrap() {

    }
}

impl Token for Contract {
    fn test_function() -> bool {
        true
    }
}
