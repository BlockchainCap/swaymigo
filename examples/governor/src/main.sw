contract;
use std::{
    address::Address,
    assert::*,
    block::*,
    contract_id::ContractId,
    hash::*,
    identity::Identity,
    storage::*,
    vec::*
};

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

struct Proposal {
    vote_start: u64,
    vote_end: u64,
    executed: bool,
    canceled: bool,
}

struct ProposalCreated {
    proposal_id: u64,
    proposer: Identity,
    start_block: u64,
    end_block: u64,
    description: Vec<b256>
}

struct VoteCast {
    voter: Identity,
    proposal_id: u64,
    support: u8,
    reason: Vec<b256>
}

struct ProposalCanceled {
    proposal_id: u64,
}

struct ProposalExecuted {
    proposal_id: u64,
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
    #[storage(read)]fn get_voring_period() -> u64;
    #[storage(read)]fn get_quorum() -> u64;
    #[storage(read)]fn has_voted(account: Identity) -> bool;
    #[storage(read, write)]fn propose(description: str[10]) -> b256;
    #[storage(read, write)]fn execute() -> b256;
    #[storage(read, write)]fn cast_vote(proposal_id: b256, support: u8) -> b256;
    // #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64;
}

storage {
    contract_id: ContractId = ~ContractId::from(0x0000000000000000000000000000000000000000000000000000000000000000),
    proposals: StorageMap<b256, Proposal> = StorageMap {},
    quorum: u64 = 0,
    voting_period: u64 = 0,
    voting_delay: u64 = 0
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
        let proposal: Proposal = storage.proposals.get(proposal_id);

        if (proposal.executed) {
            return ProposalState::Executed();
        }

        if (proposal.canceled) {
            return ProposalState::Canceled();
        }

        let snapshot_block = storage.proposals.get(proposal_id).vote_start;
        require(snapshot_block != 0, "unknown prop");
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

    #[storage(read)]pub fn get_proposal_snapshot(proposal_id: b256) -> u64 {
        storage.proposals.get(proposal_id).vote_start
    }
    #[storage(read)]pub fn get_proposal_deadline(proposal_id: b256) -> u64 {
        storage.proposals.get(proposal_id).vote_end
    }
    #[storage(read)]fn get_voting_delay() -> u64 {
        storage.voting_delay
    }
    #[storage(read)]fn get_voring_period() -> u64 {
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
        0x0000000000000000000000000000000000000000000000000000000000000000 // TODO
    }
    #[storage(read, write)]fn cast_vote(proposal_id: b256, support: u8) -> b256 {
        0x0000000000000000000000000000000000000000000000000000000000000000 // TODO
    }
    // #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64 {
    // }
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
