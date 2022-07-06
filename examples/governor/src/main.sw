contract;
use std::{address::Address, contract_id::ContractId, identity::Identity};
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
    Executed: ()
}

struct ProposalCreated {
    proposal_id: u64, 
    proposer: Identity,
    start_block: u64, 
    end_block: u64,
    description: string
}

struct VoteCast {
    voter: Identity,
    proposal_id: u64,
    support: u8,
    reason: string
}

struct ProposalCanceled {
    proposal_id: u64
}

struct ProposalExecuted {
    proposal_id: u64
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

    #[storage(read)]fn get_state(proposal_id: u64) -> ProposalState;
    #[storage(read)]fn get_proposal_snapshot(proposal_id: u64) -> u64;
    #[storage(read)]fn get_proposal_deadline(proposal_id: u64) -> u64;
    #[storage(read)]fn get_voting_delay() -> u64;
    #[storage(read)]fn get_voring_period() -> u64;
    #[storage(read)]fn get_quorum() -> u64;
    #[storage(read)]fn has_voted(account: Identity) -> bool;
    #[storage(read, write)]fn propose() -> u64;
    #[storage(read, write)]fn execute() -> u64;
    #[storage(read, write)]fn cast_vote(proposal_id: u64, support: u8) -> u64;
    #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64;
}

storage {
    contract_id: ContractId,
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

    #[storage(read)]fn get_state(proposal_id: u64) -> ProposalState {
    }
    #[storage(read)]fn get_proposal_snapshot(proposal_id: u64) -> u64 {
    }
    #[storage(read)]fn get_proposal_deadline(proposal_id: u64) -> u64 {
    }
    #[storage(read)]fn get_voting_delay() -> u64 {
    }
    #[storage(read)]fn get_voring_period() -> u64 {
    }
    #[storage(read)]fn get_quorum() -> u64 {
    }
    #[storage(read)]fn has_voted(account: Identity) -> bool {
    }
    #[storage(read, write)]fn propose() -> u64 {
    }
    #[storage(read, write)]fn execute() -> u64 {
    }
    #[storage(read, write)]fn cast_vote(proposal_id: u64, support: u8) -> u64 {
    }
    #[storage(read, write)]fn cast_vote_with_reason(proposal_id: u64, support: u8, reason: string) -> u64 {
    }
}
