contract;
use swaymigo::vault::*;

abi VaultTest {
    fn _deposit(amount: u64, receiver: Identity);
    fn _withdraw(amount: u64, receiver: Identity);
    fn _asset_id() -> u64;
    fn _total_assets() -> u64;
}

impl VaultTest for Contract {
    #[storage(read, write)]
    fn _deposit(amount: u64, receiver: Identity) {
        deposit(amount, reciever);
    }
    #[storage(read, write)]
    fn _withdraw(amount: u64, receiver: Identity) {
        withdraw(amount, reciever);
    }

    fn _get_asset_id() -> u64 {
        // unique per implementation 
        return 0; // 0 is ETH 
    }

    #[storage(read)]
    fn _get_total_assets() -> u64 {
        get_total_assets()
    }
}
