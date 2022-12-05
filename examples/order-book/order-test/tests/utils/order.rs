use crate::utils::builder::LimitOrder;
use crate::utils::environment as env;
use fuels::{
    contract::predicate::Predicate,
    prelude::{Bech32Address, Provider, TxParameters},
    signers::WalletUnlocked,
    tx::{Address, AssetId, Contract, Input, TxPointer, UtxoId},
};
const PREDICATE: &str = "../order-predicate/out/debug/order-predicate.bin";
/// Gets the message to contract predicate
pub fn get_predicate() -> (Vec<u8>, Address) {
    let predicate_bytecode = std::fs::read(PREDICATE).unwrap();
    let predicate_root = Address::from(*Contract::root_from_code(&predicate_bytecode));
    (predicate_bytecode, predicate_root)
}
pub async fn create_order(
    maker: &WalletUnlocked,
    order: &LimitOrder,
    provider: &Provider,
) -> (Predicate, Input) {
    let predicate = Predicate::load_from(PREDICATE).unwrap();
    let (predicate_bytecode, predicate_root) = get_predicate();
    // create the order (fund the predicate)
    let (_tx, _rec) = maker
        .transfer(
            predicate.address(),
            order.maker_amount,
            AssetId::from(order.maker_token.0),
            TxParameters::default(),
        )
        .await
        .unwrap();
    let predicate_coin = &provider
        .get_coins(&predicate_root.into(), AssetId::default())
        .await
        .unwrap()[0];
    let predicate_coin_input = Input::CoinPredicate {
        utxo_id: UtxoId::from(predicate_coin.utxo_id.clone()),
        owner: predicate_root,
        amount: order.maker_amount,
        asset_id: AssetId::from(order.maker_token.0),
        tx_pointer: TxPointer::default(),
        maturity: 0,
        predicate: predicate_bytecode,
        predicate_data: vec![],
    };
    (predicate, predicate_coin_input)
}

pub async fn verify_balance_of_maker_and_predicate(
    maker: &WalletUnlocked,
    predicate: &Bech32Address,
    asset: AssetId,
    amount: u64,
    provider: &Provider,
) {
    let balance = maker.get_asset_balance(&asset).await.unwrap();
    let predicate_balance = provider.get_asset_balance(predicate, asset).await.unwrap();
    assert!(balance == 0);
    assert!(predicate_balance == amount);
}

pub async fn take_order(
    taker: &WalletUnlocked,
    order: &LimitOrder,
    provider: &Provider,
    predicate_coin_input: Input,
    gas_coin_inputs: Input,
) {
    let input_coins = &provider
        .get_coins(&taker.address(), AssetId::default())
        .await
        .unwrap()[0];
    let taker_coin_input = Input::CoinSigned {
        utxo_id: UtxoId::from(input_coins.utxo_id.clone()),
        owner: taker.address().into(),
        amount: input_coins.amount.clone().into(),
        asset_id: input_coins.asset_id.clone().into(),
        tx_pointer: TxPointer::default(),
        witness_index: 0,
        maturity: 0,
    };
    let _receipt = env::take_order(
        order,
        &taker,
        gas_coin_inputs,
        predicate_coin_input,
        &vec![taker_coin_input],
        &vec![],
    )
    .await;
}
pub async fn verify_balance_post_swap(
    maker: &WalletUnlocked,
    taker: &WalletUnlocked,
    predicate_address: &Bech32Address,
    order: LimitOrder,
    provider: &Provider,
) {
    let maker_token = AssetId::from(order.maker_token.0);
    let taker_token = AssetId::from(order.taker_token.0);
    let balance_maker = maker.get_asset_balance(&taker_token).await.unwrap();
    let balance_taker = taker.get_asset_balance(&maker_token).await.unwrap();
    let predicate_balance = provider
        .get_asset_balance(predicate_address, maker_token)
        .await
        .unwrap();
    assert!(balance_maker == order.taker_amount);
    assert!(balance_taker == order.maker_amount);
    assert!(predicate_balance == 0);
}

// // for debugging purposes
// async fn print_balances(
//     maker: &WalletUnlocked,
//     taker: &WalletUnlocked,
//     predicate_address: &Bech32Address,
//     provider: &Provider,
//     coin: (u64, AssetId),
// ) {
//     let maker = maker.get_asset_balance(&coin.1).await.unwrap();
//     let taker = taker.get_asset_balance(&coin.1).await.unwrap();
//     let pred_b = provider
//         .get_asset_balance(predicate_address, coin.1)
//         .await
//         .unwrap();
//     println!("----------- COINS ----------");
//     println!("Maker balance after: {:?}", maker);
//     println!("Taker balance after: {:?}", taker);
//     println!("Predicate balance after: {:?}", pred_b);
//     println!("----------------------------");
// }
