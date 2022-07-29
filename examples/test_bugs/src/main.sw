contract;
use std::storage::*;

struct StorageInStruct {
    s_m: StorageMap<b56, bool> {},
}
storage {
    s: StorageInStruct{}
}
abi MyContract {
    fn test_function() -> bool;
}

impl MyContract for Contract {
    fn test_function() -> bool {
        true
    }
}
