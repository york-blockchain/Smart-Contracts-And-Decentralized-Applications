// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

// contract definition starts
contract Token is Ownable {
    struct Balance {
        uint256 balance;
        uint256 timestamp;
    }
    // declare variable `accountHolders` of type mapping
    // it will hold the balance of the account holders against
    // account holder’s address
    mapping(address => Balance) public accountHolders;
    // event declaration for `Transfer` event emission
    event Transferred(
        address indexed _from,
        address indexed _to,
        uint256 indexed _amount
    );

    // declare `mint` function with two arguments
    function mint(address receiver, uint256 value) public onlyOwner {
        // the value of `value` cannot exceed 10^60
        // the maximum value a uint256 type can hold is
        // equal to 2^256
        require(value < 10**60, "Error: value cannot exceed 10^60");
        accountHolders[receiver].timestamp = now;
        // add the value to receiver’s account
        accountHolders[receiver].balance += value;
    }

    // `transfer` function to send tokens from one account to
    // another
    function transfer(address receiver, uint256 value) public {
        // make sure the caller has enough token
        require(
            accountHolders[msg.sender].balance >= value,
            "Error: Caller does not have enough tokens"
        );
        // reduce the value from caller’s account
        accountHolders[msg.sender].timestamp = now;
        accountHolders[msg.sender].balance -= value;
        accountHolders[receiver].timestamp = now;
        // add the value to receiver’s account
        accountHolders[receiver].balance += value;
        // emit a Transferred event with sender’s address
        // receiver’s address and value sent.
        emit Transferred(msg.sender, receiver, value);
    }
} // Ends here
