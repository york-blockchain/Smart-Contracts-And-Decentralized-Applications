// SPDX-License-Identifier: MIT
// The above line tells that source code is licensed under MIT

// specify the solidity version
pragma solidity ^0.6.10;

// contract definition starts
contract Token {
    // declare variable `owner` of type address
    address public owner;
    // declare variable `accountHolders` of type mapping
    // it will hold the balance of the account holders against
    // account holder’s address
    mapping(address => uint256) public accountHolders;
    // event declaration for `Transfer` event emission
    event Transferred(
        address indexed _from,
        address indexed _to,
        uint256 indexed _amount
    );

    // declare a function called `constructor` with public
    // visibility
    // the `constructor` only executes once in entire life
    // cycle i.e. during contract deployment
    constructor() public {
        // initialise owner with contract deployer’s account
        owner = msg.sender;
    }

    // declare `mint` function with two arguments
    function mint(address receiver, uint256 value) public {
        // only owner of the contract can call `mint`
        require(owner == msg.sender, "Error: caller must be same as creator");
        // the value of `value` cannot exceed 10^60
        // the maximum value a uint256 type can hold is
        // equal to 2^256
        require(value < 10**60, "Error: value cannot exceed 10^60");
        // add the value to receiver’s account
        accountHolders[receiver] += value;
    }

    // `transfer` function to send tokens from one account to
    // another
    function transfer(address receiver, uint256 value) public {
        // make sure the caller has enough token
        require(
            accountHolders[msg.sender] >= value,
            "Error: Caller does not have enough tokens"
        );
        // reduce the value from caller’s account
        accountHolders[msg.sender] -= value;
        // add the value to receiver’s account
        accountHolders[receiver] += value;
        // emit a Transferred event with sender’s address
        // receiver’s address and value sent.
        emit Transferred(msg.sender, receiver, value);
    }
} // Ends here
