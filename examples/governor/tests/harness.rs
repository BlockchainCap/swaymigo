use fuels::{prelude::*};

// Load abi from json
abigen!(Governor, "out/debug/governor-abi.json");

async fn get_contract_instance() -> (Governor, ContractId, WalletUnlocked) {
    // Launch a local network and deploy the contract
    let wallet = launch_provider_and_get_wallet().await;

    let id = Contract::deploy(
        "./out/debug/governor.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::default(),
    )
    .await
    .unwrap();

    let instance = GovernorBuilder::new(id.to_string(), wallet.clone()).build();

    // init defaults ==> this should prob not be necessary
    let _ = instance.set_voting_period(10).call().await;
    let _ = instance.set_voting_delay(3).call().await;
    let _ = instance.set_quorum(1).call().await;

    (instance, id.into(), wallet)
}

#[tokio::test]
async fn create_proposal() {
    let (_instance, _id, deployer) = get_contract_instance().await;
    // let wallet = WalletUnlocked::new_random(None);
    let address: Address = deployer.address().into();
    _instance
        .mint(governor_mod::Identity::Address(address), 100)
        .call()
        .await
        .unwrap();

    let voting_power = _instance
        .get_voting_power(
            height(deployer.clone()).await,
            governor_mod::Identity::Address(address),
        )
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(voting_power, 100);

    // create a proposal
    let prop_hash = _instance
        .propose("test test ".to_string())
        .call()
        .await
        .unwrap()
        .value;
    let deadline = _instance
        .get_proposal_deadline(prop_hash)
        .simulate()
        .await
        .unwrap()
        .value;
    let snapshot = _instance
        .get_proposal_snapshot(prop_hash)
        .simulate()
        .await
        .unwrap()
        .value;
    let voting_period = _instance
        .get_voting_period()
        .simulate()
        .await
        .unwrap()
        .value;
    let state = _instance
        .get_state(prop_hash)
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(state, governor_mod::ProposalState::Pending());
    let mut state = state;
    // simulate the chain getting to the active state (all calls append a new block)
    while state != governor_mod::ProposalState::Active() {
        state = _instance.get_state(prop_hash).call().await.unwrap().value;
    }
    let vote_start = _instance
        .get_proposal_snapshot(prop_hash)
        .simulate()
        .await
        .unwrap()
        .value;
    
    let vp_for_prop = _instance
        .get_voting_power(vote_start, governor_mod::Identity::Address(address))
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(deadline, snapshot + voting_period);
    assert_eq!(vp_for_prop, 100);

    // 0 is 'for'
    let vote = _instance
        .cast_vote(prop_hash, 0)
        .call()
        .await
        .unwrap()
        .value;
    assert_eq!(vote, 100);
    let vote2 = _instance.cast_vote(prop_hash, 0).call().await;
    assert!(vote2.is_err()); // should not be able to vote 2 times
    let mut state = _instance
        .get_state(prop_hash)
        .simulate()
        .await
        .unwrap()
        .value;
    assert_eq!(state, governor_mod::ProposalState::Active());
    while state != governor_mod::ProposalState::Succeeded() {
        state = _instance.get_state(prop_hash).call().await.unwrap().value;
    }
    let vote2 = _instance.cast_vote(prop_hash, 0).call().await;
    assert!(vote2.is_err()); // should not be able to vote after deadline

    let exec = _instance.execute(prop_hash).call().await.unwrap().value;
    assert_eq!(exec, prop_hash);
    state = _instance.get_state(prop_hash).call().await.unwrap().value;
    assert_eq!(state, governor_mod::ProposalState::Executed());
}

async fn height(w: WalletUnlocked) -> u64 {
    w.get_provider()
        .unwrap()
        .latest_block_height()
        .await
        .unwrap()
}
