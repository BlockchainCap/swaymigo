contract;
use std::{
    address::Address,
    assert::*,
    revert::*,
    block::*,
    contract_id::ContractId,
    hash::*,
    chain::auth::msg_sender,
    identity::Identity,
    storage::*,
    vec::*,
    logging::*
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
        match (self, other) {
            (ProposalState::Pending, ProposalState::Pending) => true,
            (ProposalState::Active, ProposalState::Active) => true,
            (ProposalState::Canceled, ProposalState::Canceled) => true,
            (ProposalState::Defeated, ProposalState::Defeated) => true,
            (ProposalState::Succeeded, ProposalState::Succeeded) => true,
            (ProposalState::Queued, ProposalState::Queued) => true,
            (ProposalState::Expired, ProposalState::Expired) => true,
            (ProposalState::Executed, ProposalState::Executed) => true, 
            _ => false,
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
    // has_voted: StorageMap<Identity, bool> {},
}

struct ProposalCreated {
    proposal_id: b256,
    proposer: Identity,
    start_block: u64,
    end_block: u64,
    description: Vec<b256>,
}

struct VoteCast {
    voter: Identity,
    proposal_id: b256,
    support: u8,
    weight: u64
    // reason: Vec<b256>,
}

struct ProposalCanceled {
    proposal_id: b256,
}

struct ProposalExecuted {
    proposal_id: b256,
}

abi Governor {
    #[storage(read, write)]pub fn mint(to: Identity, amount: u64);
    #[storage(read, write)]pub fn burn(from: Identity, amount: u64);
    #[storage(write)]fn set_vote_asset(contract_id: ContractId);
    #[storage(read)]fn get_vote_asset() -> ContractId;
    #[storage(read, write)]fn transfer(from: Identity, to: Identity, amount: u64);
    #[storage(read, write)]fn delegate(from: Identity, to: Identity, amount: u64);
    #[storage(read)]fn get_supply_checkpoint(block: u64) -> u64;
    #[storage(read)]fn get_voting_power(block: u64, of: Identity) -> u64;

    #[storage(read)]fn get_state(proposal_id: b256) -> ProposalState;
    #[storage(read)]fn get_proposal_snapshot(proposal_id: b256) -> u64;
    #[storage(read)]fn get_proposal_deadline(proposal_id: b256) -> u64;
    #[storage(read)]fn get_voting_delay() -> u64;
    #[storage(read)]fn get_voting_period() -> u64;
    #[storage(read)]fn get_quorum() -> u64;
    #[storage(read)]fn has_voted(account: Identity) -> bool;
    #[storage(read, write)]fn propose(description: str[10]) -> b256;
    #[storage(read, write)]fn execute() -> b256;
    #[storage(read, write)]fn cast_vote(proposal_id: b256, support: u8) -> u64;
    // #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64;
}

storage {
    contract_id: ContractId = ~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000000000),
    proposals: StorageMap<b256,
    Proposal> = StorageMap {
    },
    proposal_votes: StorageMap<b256, ProposalVotes> = StorageMap {},
    has_voted: StorageMap<b256, bool> = StorageMap {},
    quorum: u64 = 0,
    voting_period: u64 = 0,
    voting_delay: u64 = 0,
}

impl Governor for Contract {
    #[storage(read, write)]pub fn mint(to: Identity, amount: u64) {
        _mint(to, amount);
    }

    #[storage(read, write)]pub fn burn(from: Identity, amount: u64) {
        _burn(from, amount);
    }

    #[storage(write)]pub fn set_vote_asset(contract_id: ContractId) {
        storage.contract_id = contract_id;
    }

    #[storage(read)]pub fn get_vote_asset() -> ContractId {
        return storage.contract_id;
    }

    #[storage(read, write)]pub fn transfer(from: Identity, to: Identity, amount: u64) {
        _transfer(from, to, amount);
    }

    #[storage(read, write)]pub fn delegate(from: Identity, to: Identity, amount: u64) {
        _delegate(from, to, amount);
    }

    #[storage(read)]pub fn get_supply_checkpoint(block: u64) -> u64 {
        _get_supply_checkpoint(block)
    }

    #[storage(read)]pub fn get_voting_power(block: u64, of: Identity) -> u64 {
        _get_voting_power(block, of)
    }

    #[storage(read)]pub fn get_state(proposal_id: b256) -> ProposalState {
        _get_state(proposal_id)
    }

    #[storage(read)]pub fn get_proposal_snapshot(proposal_id: b256) -> u64 {
        storage.proposals.get(proposal_id).vote_start
    }
    #[storage(read)]pub fn get_proposal_deadline(proposal_id: b256) -> u64 {
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
    #[storage(read)]fn has_voted(account: Identity) -> bool {
        // TODO
        false
    }
    // TODO: need dynamic strings or alternatively just use bytes
    #[storage(read, write)]fn propose(description: str[10]) -> b256 {
        let prop_hash = sha256(description);
        let proposal = Proposal {
            vote_start: height() + storage.voting_delay,
            vote_end: height() + storage.voting_delay + storage.voting_period,
            executed: false,
            canceled: false,
        };
        storage.proposals.insert(prop_hash, proposal);
        prop_hash
    }
    #[storage(read, write)]fn execute() -> b256 {
        // TODO: There is a whole bunch missing to make this work, basically we need to delegate a 
        // call to another contract and the proposal itself should have the transaction basically
        // fully constructed
        0x0000000000000000000000000000000000000000000000000000000000000000 // TODO
    }
    #[storage(read, write)]fn cast_vote(proposal_id: b256, support: u8) -> u64 {
        let proposal = storage.proposals.get(proposal_id);
        assert(_get_state(proposal_id) == ProposalState::Active());

        let voter = get_msg_sender_id_or_panic(msg_sender());
        let weight = _get_voting_power(proposal.vote_start, voter);

        count_vote(proposal_id, voter, support, weight); 
        log(VoteCast {
            voter: voter, 
            proposal_id: proposal_id,
            support: support,
            weight: weight
            // reason: Vec<b256>,
        });
        weight
    }
    // #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64 {
    // }
}

#[storage(read, write)]
fn count_vote(proposal_id: b256, voter: Identity, support: u8, weight: u64) {
    let proposal_vote = storage.proposal_votes.get(proposal_id);
    let vote_id = sha256((proposal_id, voter));
    // require(!storage.has_voted.get(vote_id), "Already vote");
    assert(!storage.has_voted.get(vote_id));
    storage.has_voted.insert(vote_id, true);
    match support {
        0 => {
           storage.proposal_votes.insert(proposal_id, ProposalVotes {
                votes_for: proposal_vote.votes_for + weight,
                votes_against: proposal_vote.votes_against, 
                votes_abstain: proposal_vote.votes_abstain,
           }) 
        },
        1 => {
           storage.proposal_votes.insert(proposal_id, ProposalVotes {
                votes_for: proposal_vote.votes_for,
                votes_against: proposal_vote.votes_against + weight, 
                votes_abstain: proposal_vote.votes_abstain
           }) 
        },
        2 => {
           storage.proposal_votes.insert(proposal_id, ProposalVotes {
                votes_for: proposal_vote.votes_for,
                votes_against: proposal_vote.votes_against,
                votes_abstain: proposal_vote.votes_abstain + weight
           }) 
        },
        _ => revert(0),
    }
}
/// internal functions
fn quorum_reached(proposal_id: b256) -> bool {
    // TODO
    false
}

fn vote_succeeded(proposal_id: b256) -> bool {
    // TODO
    false
}


#[storage(read)]
fn _get_state(proposal_id: b256) -> ProposalState {
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