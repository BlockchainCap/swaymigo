mod utils {
    pub mod builder;
    pub mod environment;
    pub mod order;
}

mod success {
    use crate::utils::builder::LimitOrder;

    use fuels::{
        prelude::{Bits256, Token, Tokenizable},
        test_helpers::DEFAULT_COIN_AMOUNT,
        tx::AssetId,
    };

    use crate::{utils::environment as env, utils::order as ord};

    #[tokio::test]
    async fn test_limit_order_predicate() {
        let coin = (DEFAULT_COIN_AMOUNT, AssetId::default());
        let (maker, taker, coin_inputs, provider) = env::setup_environment(coin).await;
        let order = LimitOrder {
            maker: maker.address().into(),
            maker_amount: coin.0,
            taker_amount: coin.0 / 2,
            maker_token: Bits256::from_token(Token::B256([0u8; 32])).unwrap(),
            taker_token: Bits256::from_token(Token::B256([0u8; 32])).unwrap(),
            salt: 42,
        };
        let (predicate, predicate_input_coin) = ord::create_order(&maker, &order, &provider).await;
        ord::verify_balance_of_maker_and_predicate(
            &maker,
            predicate.address(),
            coin.1,
            coin.0,
            &provider,
        )
        .await;
        ord::take_order(
            &taker,
            &order,
            &provider,
            predicate_input_coin,
            coin_inputs[0].clone(),
        )
        .await;
        ord::verify_balance_post_swap(&maker, &taker, predicate.address(), order, &provider).await;
    }
}

mod fail {
    use crate::utils::builder::LimitOrder;

    use fuels::{
        prelude::{Bits256, Token, Tokenizable},
        test_helpers::DEFAULT_COIN_AMOUNT,
        tx::AssetId,
    };

    use crate::{utils::environment as env, utils::order as ord};

    #[tokio::test]
    async fn test_limit_order_predicate_wrong_take_coin() {
        let coin = (DEFAULT_COIN_AMOUNT, AssetId::default());
        let (maker, taker, coin_inputs, provider) = env::setup_environment(coin).await;
        let order = LimitOrder {
            maker: maker.address().into(),
            maker_amount: coin.0,
            taker_amount: coin.0 / 2,
            maker_token: Bits256::from_token(Token::B256([0u8; 32])).unwrap(),
            taker_token: Bits256::from_token(Token::B256([0u8; 32])).unwrap(),
            salt: 42,
        };
        let (predicate, predicate_input_coin) = ord::create_order(&maker, &order, &provider).await;
        ord::verify_balance_of_maker_and_predicate(
            &maker,
            predicate.address(),
            coin.1,
            coin.0,
            &provider,
        )
        .await;
        ord::take_order(
            &taker,
            &order,
            &provider,
            predicate_input_coin,
            coin_inputs[0].clone(),
        )
        .await;
        ord::verify_balance_post_swap(&maker, &taker, predicate.address(), order, &provider).await;
    }
}
