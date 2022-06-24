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


## Known Issues
Sway is nascent. There are missing features and some lack of cleanliness. For now this contracts work around these issues to the best of our ability. Expect the contracts to evolve over time as the language itself evolves.
Workarounds/hacks include: 
- Manual storage manipulation in libraries because `storage` keyword and StorageMap not yet supported in libs
- Low level asset manipulation not being utilized (implementation detail for now)


# Disclaimer
Current iteration of contracts written here are un-audited and are presented for demonstration purposes only. These contracts are not considered production ready. If you or your team is looking to build a Fuel application using the swaymigo library, reach out to ryan@blockchaincapital.com

