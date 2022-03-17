# Coding Activity

Develop a contract that handles time. Use Remix IDE  to test the contract as learnt in [this](../../class-2/asynchronous/README.md) activity.
## Background
- In order to make your smart contract to transactions differently after some point in the future, the contract needs to have a way to express and store values that represent time. 
- The Ethereum Virtual Machine represents time as the (integer) number of seconds since the “Unix epoch”, and the current time is accessible to a Solidity program as now, which is an alias for block.timestamp.

- You will create a the code that does nothing beyond remembering when it was created:

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract Time {
    uint256 public createTime;

    constructor() public {
        createTime = block.timestamp;
    }
}
```
## Explanation

- The system-defined variable `block.timestamp` contains the current time in seconds since the Unix epoch. This is defined as the timestamp of the block (on the blockchain) that the transaction is a part of.

- The natural unit of time in the EVM is seconds.

### Relative Time
- To demonstrate using time to influence transaction processing, you'll develop a smart contract that saves save money for a specified period of time. 
- During that period, you (or anybody else!) can deposit ether in the contract, but the contract will not let you withdraw any ether until the waiting period is over.
- Solidity has “time units” built in. You can specify 3 days or 60 months, for instance. The savings contract will be parameterized by a waiting period specified in days. 
- Because the EVM naturally stores time in seconds, the contract must scale the waiting period by the number of seconds in a day, which is given by the literal 1 days in Solidity.

`savings.sol`

```js
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract Savings {
    address owner;
    uint256 deadline;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function deposit(uint256 amount) public payable {
        require(msg.value == amount);
    }

    constructor(uint256 numberOfDays) public payable {
        owner = msg.sender;
        deadline = block.timestamp + (numberOfDays * 1 days);
    }

    function withdraw() public onlyOwner {
        require(block.timestamp >= deadline);

        msg.sender.transfer(address(this).balance);
    }
}
```

**The code above demonstrates the following concepts:**

- `(numberOfDays * 1 days)` computes the time in seconds in `numberOfDays` days.
- `block.timestamp + (numberOfDays * 1 days)` computes the EVM time that represents `numberOfDays` days in the future.
- `block.timestamp >= deadline` tests if the current time is greater than or equal to deadline. (I.e, has the deadline passed?)
- The Savings contract is parameterized by the number of days during which no withdrawals are permitted. During that period, any withdraw transactions will simply fail. After that time has elapsed, withdrawals will succeed.

- Deposits are allowed at any time. Note also that the constructor has the payable modifier, which allows ether to be attached (and transferred) to the contract during deployment.

**Key Takeaways**
- Each block in the blockchain includes a timestamp specified as the number of seconds since the Unix epoch. Time values are integers.
- Solidity smart contracts can access the timestamp of the current block as `block.timestamp`.
- Solidity provides convenient time units like days and months, which are helpful in computing time spans.

#### References
- [Units and Globally Available Variables](https://docs.soliditylang.org/en/v0.6.10/units-and-global-variables.html#units-and-globally-available-variables)