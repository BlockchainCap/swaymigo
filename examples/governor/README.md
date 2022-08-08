# Governor
Example implementation for a governance style contract.

### To run tests: 
```bash
forc build 
forc test 
```


# Limitations
- Currently this does not include the logic to execute transactions. There is a skeleton for this functionality. 
- Does not allow indication of reason for voting as in the OZ style governance contract
- Does not allow dynamic string to be passed with proposal. Hard coded a hacked of 10 character proposal. 
