contract;
use std::{
    address::Address,
    assert::*,
    block::*,
    chain::auth::msg_sender,
    contract_id::ContractId,
    hash::*,
    identity::Identity,
    logging::*,
    revert::*,
    storage::*,
    vec::*,
};

use swaymigo::auth::sender::*;
use swaymigo::token::vote_token::{
    burn as _burn,
    delegate as _delegate,
    get_supply_checkpoint as _get_supply_checkpoint,
    get_voting_power as _get_voting_power,
    mint as _mint,
    transfer as _transfer,
};

enum ProposalState {
    Pending: (),
    Active: (),
    Canceled: (),
    Defeated: (),
    Succeeded: (),
    Queued: (),
    Expired: (),
    Executed: (),
}

// wouldn't need this if we had PartialEq
impl core::ops::Eq for ProposalState {
    fn eq(self, other: Self) -> bool {
        match(self, other) {
            (ProposalState::Pending, ProposalState::Pending) => true, (ProposalState::Active, ProposalState::Active) => true, (ProposalState::Canceled, ProposalState::Canceled) => true, (ProposalState::Defeated, ProposalState::Defeated) => true, (ProposalState::Succeeded, ProposalState::Succeeded) => true, (ProposalState::Queued, ProposalState::Queued) => true, (ProposalState::Expired, ProposalState::Expired) => true, (ProposalState::Executed, ProposalState::Executed) => true, _ => false, 
        }
    }
}

struct Proposal {
    vote_start: u64,
    vote_end: u64,
    executed: bool,
    canceled: bool,
}

struct ProposalVotes {
    votes_for: u64,
    votes_against: u64,
    votes_abstain: u64,
    // no possible to have a storage map inside of a struct
    // has_voted: StorageMap<Identity, bool> {},
}

struct ProposalCreated {
    proposal_id: b256,
    proposer: Identity,
    start_block: u64,
    end_block: u64,
    // description: Vec<b256>,
}

struct VoteCast {
    voter: Identity,
    proposal_id: b256,
    support: u8,
    weight: u64, // reason: Vec<b256>,
}

struct ProposalCanceled {
    proposal_id: b256,
}

struct ProposalExecuted {
    proposal_id: b256,
}

abi Governor {
    #[storage(read, write)]fn mint(to: Identity, amount: u64);
    #[storage(read, write)]fn burn(from: Identity, amount: u64);
    #[storage(write)]fn set_vote_asset(contract_id: ContractId);
    #[storage(read)]fn get_vote_asset() -> ContractId;
    #[storage(read, write)]fn transfer(from: Address, to: Address, amount: u64);
    #[storage(read, write)]fn delegate(from: Address, to: Address, amount: u64);
    #[storage(read)]fn get_supply_checkpoint(block: u64) -> u64;
    #[storage(read)]fn get_voting_power(block: u64, of: Identity) -> u64;

    #[storage(read)]fn get_state(proposal_id: b256) -> ProposalState;
    #[storage(read)]fn get_proposal_snapshot(proposal_id: b256) -> u64;
    #[storage(read)]fn get_proposal_deadline(proposal_id: b256) -> u64;
    #[storage(read)]fn get_voting_delay() -> u64;
    #[storage(read)]fn get_voting_period() -> u64;
    #[storage(read)]fn get_quorum() -> u64;
    #[storage(read)]fn get_total_voted(proposal_id: b256) -> u64;
    #[storage(write)]fn set_voting_delay(vd: u64);
    #[storage(write)]fn set_voting_period(vp: u64);
    #[storage(write)]fn set_quorum(quorum: u64);
    #[storage(read)]fn has_voted(proposal_id: b256, account: Identity) -> bool;
    #[storage(read, write)]fn propose(description: str[10]) -> b256;
    #[storage(read, write)]fn execute(proposal_id: b256) -> b256;
    #[storage(read, write)]fn cast_vote(proposal_id: b256, support: u8) -> u64;
    // #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64;
}

storage {
    contract_id: ContractId = ~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000000000),
    proposals: StorageMap<b256,
    Proposal> = StorageMap {
    },
    proposal_votes: StorageMap<b256,
    ProposalVotes> = StorageMap {
    },
    has_voted: StorageMap<b256,
    bool> = StorageMap {
    },
    quorum: u64 = 0,
    voting_period: u64 = 0,
    voting_delay: u64 = 0,
}

impl Governor for Contract {
    #[storage(read, write)]fn mint(to: Identity, amount: u64) {
        _mint(to, amount);
    }

    #[storage(read, write)]fn burn(from: Identity, amount: u64) {
        _burn(from, amount);
    }

    #[storage(write)]fn set_vote_asset(contract_id: ContractId) {
        storage.contract_id = contract_id;
    }

    #[storage(read)]fn get_vote_asset() -> ContractId {
        return storage.contract_id;
    }

    #[storage(read, write)]fn transfer(from: Address, to: Address, amount: u64) {
        _transfer(Identity::Address(from), Identity::Address(to), amount);
    }

    #[storage(read, write)]fn delegate(from: Address, to: Address, amount: u64) {
        _delegate(Identity::Address(from), Identity::Address(to), amount);
    }

    #[storage(read)]fn get_supply_checkpoint(block: u64) -> u64 {
        _get_supply_checkpoint(block)
    }

    #[storage(read)]fn get_voting_power(block: u64, of: Identity) -> u64 {
        _get_voting_power(block, of)
    }

    #[storage(read)]fn get_state(proposal_id: b256) -> ProposalState {
        _get_state(proposal_id)
    }

    #[storage(read)]fn get_proposal_snapshot(proposal_id: b256) -> u64 {
        storage.proposals.get(proposal_id).vote_start
    }
    
    #[storage(read)]fn get_proposal_deadline(proposal_id: b256) -> u64 {
        storage.proposals.get(proposal_id).vote_end
    }

    #[storage(read)]fn get_voting_delay() -> u64 {
        storage.voting_delay
    }

    #[storage(read)]fn get_voting_period() -> u64 {
        storage.voting_period
    }

    #[storage(read)]fn get_quorum() -> u64 {
        storage.quorum
    }

    // CONFIG SET -- should be restricted auth
    #[storage(write)]fn set_voting_delay(vd: u64) {
        storage.voting_delay = vd;
    }

    #[storage(write)]fn set_voting_period(vp: u64) {
        storage.voting_period = vp;
    }

    #[storage(write)]fn set_quorum(quorum: u64) {
        storage.quorum = quorum;
    }

    #[storage(read)] fn get_total_voted(proposal_id: b256) -> u64 {
        _get_total_voted(proposal_id)
    }

    #[storage(read)]fn has_voted(proposal_id: b256, account: Identity) -> bool {
        let vote_id = sha256((proposal_id, account));
        storage.has_voted.get(vote_id)
    }

    // TODO: need dynamic strings or alternatively just use bytes
    #[storage(read, write)]fn propose(description: str[10]) -> b256 {
        let prop_hash = sha256(description);
        let proposer = get_msg_sender_id_or_panic(msg_sender());
        let start = height() + storage.voting_delay;
        let end = height() + storage.voting_delay + storage.voting_period;
        let proposal = Proposal {
            vote_start: start,
            vote_end: end,
            executed: false,
            canceled: false,
        };
        storage.proposals.insert(prop_hash, proposal);
        log(ProposalCreated {
            proposal_id: prop_hash, proposer: proposer, start_block: start, end_block: end
        });
        prop_hash
    }
    #[storage(read, write)]fn execute(proposal_id: b256) -> b256 {
        // TODO: There is a whole bunch missing to make this work, we need to delegate a
        // call to another contract and the proposal itself should have the transaction basically
        // fully constructed
        let state = _get_state(proposal_id);
        assert(state == ProposalState::Succeeded());
         // DO EXECUTION 
        let mut proposal = storage.proposals.get(proposal_id);
        proposal.executed = true;
        storage.proposals.insert(proposal_id, proposal);
        log(ProposalExecuted {
            proposal_id: proposal_id
        });
        proposal_id
    }

    #[storage(read, write)]fn cast_vote(proposal_id: b256, support: u8) -> u64 {
        let proposal = storage.proposals.get(proposal_id);
        assert(_get_state(proposal_id) == ProposalState::Active());

        let voter = get_msg_sender_id_or_panic(msg_sender());
        let weight = _get_voting_power(proposal.vote_start, voter);
        assert(weight > 0);
        count_vote(proposal_id, voter, support, weight);
        log(VoteCast {
            voter: voter, proposal_id: proposal_id, support: support, weight: weight
        });
        weight
    }

    // #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64 {
    //     // TODO 
    //     revert(0);
    // }
}
   
#[storage(read, write)]fn count_vote(proposal_id: b256, voter: Identity, support: u8, weight: u64) {
    let proposal_vote = storage.proposal_votes.get(proposal_id);
    let vote_id = sha256((proposal_id, voter));
    // require(!storage.has_voted.get(vote_id), "Already vote");
    assert(!storage.has_voted.get(vote_id));
    storage.has_voted.insert(vote_id, true);
    match support {
        0 => {
            storage.proposal_votes.insert(proposal_id, ProposalVotes {
                votes_for: proposal_vote.votes_for + weight, votes_against: proposal_vote.votes_against, votes_abstain: proposal_vote.votes_abstain, 
            })
        },
        1 => {
            storage.proposal_votes.insert(proposal_id, ProposalVotes {
                votes_for: proposal_vote.votes_for, votes_against: proposal_vote.votes_against + weight, votes_abstain: proposal_vote.votes_abstain
            })
        },
        2 => {
            storage.proposal_votes.insert(proposal_id, ProposalVotes {
                votes_for: proposal_vote.votes_for, votes_against: proposal_vote.votes_against, votes_abstain: proposal_vote.votes_abstain + weight
            })
        },
        _ => revert(0), 
    }
}
/// internal functions
#[storage(read)]fn quorum_reached(proposal_id: b256) -> bool {
    let total_votes = _get_total_voted(proposal_id);
    return total_votes >= storage.quorum;
}

#[storage(read)]fn vote_succeeded(proposal_id: b256) -> bool {
    let votes = storage.proposal_votes.get(proposal_id);
    let non_yes = votes.votes_against + votes.votes_abstain;
    // this is simple majority, probably want more expressiveness here
    return votes.votes_for > non_yes;
}
#[storage(read)] fn _get_total_voted(proposal_id: b256) -> u64 {
    let votes = storage.proposal_votes.get(proposal_id);
    let total_votes = votes.votes_for + votes.votes_against + votes.votes_abstain;
    total_votes
}

#[storage(read)]fn _get_state(proposal_id: b256) -> ProposalState {
    let proposal: Proposal = storage.proposals.get(proposal_id);

    if (proposal.executed) {
        return ProposalState::Executed();
    }

    if (proposal.canceled) {
        return ProposalState::Canceled();
    }

    let snapshot_block = storage.proposals.get(proposal_id).vote_start;
    // require(snapshot_block != 0, "unknown prop");
    assert(snapshot_block != 0);
    if (snapshot_block > height()) {
        return ProposalState::Pending();
    }

    let deadline = storage.proposals.get(proposal_id).vote_end;
    if (deadline >= height()) {
        return ProposalState::Active();
    }

    if (quorum_reached(proposal_id) && vote_succeeded(proposal_id)) {
        return ProposalState::Succeeded();
    } else {
        return ProposalState::Defeated();
    }
}
