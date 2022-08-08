# Swaymigo 
Some common building blocks for Sway smart contracts in the FuelVM.



## To run the swaymigo test suite 

Build the test harness under `test/`. Run: 
``` sh
cd test
./build.sh
```

Run the tests after the tests have been built successfuly: 
``` sh 
cargo test 
```

# Currently available
### Tokens
- [x] Fungible Token - A ledger based erc20 style token implementation. This does not take advantage of the FuelVM internal asset management system. This might be useful for scenario where the ledger state is an important part of the wrapper contracts implementation. For example a vote token that needs historical snapshots of the ledger state for each voter. 
- [x] Non-fungible token - A simple library that implements the ERC721 standard
- [x] Vote token - A snapshotting token that allows for historical balance look ups based on block number. This is good for a governance use case. 
- [x] Wrapper Token - A ledger based token wrapper for native assets. Good if you want to give snapshotting functionality to a native asset. 
- [x] Vault token - Token that follows ERC4626 vault standard. 
### Utils
- [ ] Merkle Proof verifier - not yet implemented because of limitations with dynamic collections in contract ABIs
- [ ] Strings - Not yet implemented. helpers for string manipulation

## Auth
- [x] Sender - helper to get the msg.sender or revert
- [ ] Ownership - not yet implemented

# Known Issues
Sway is nascent. There are missing features and some lack of cleanliness. For now this contracts work around these issues to the best of our ability. Expect the contracts to evolve over time as the language itself evolves.
Workarounds/hacks include: 
- Manual storage manipulation in libraries because `storage` keyword and StorageMap not yet supported in libs
- Low level asset manipulation not being utilized 
- Test coverage is pretty weak


# Disclaimer
Current iteration of contracts written here are un-audited and are presented for demonstration purposes only. These contracts are not considered production ready. If you or your team is looking to build a Fuel application using the swaymigo library, reach out to ryan@blockchaincapital.com

