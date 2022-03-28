// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

/**
 * @author Dhruvin Parikh
 * @title SimpleStorage
*/

// Contract declaration
contract SimpleStorage {
    // state variables
    uint256 public number;
    
    // constructor - executed ONLY once while contract is deployed
    constructor (uint _number) public {
        number = _number;
    }
    
    function increment() public {
        number++;
        // emit events
        emit Increment(number,msg.sender);
    }
    
    function decrement() public {
        number--;
        // emit events
        emit Decrement(number,msg.sender);

    }
    
    // events
    event Increment(uint256 indexed number, address indexed caller);
    event Decrement(uint256 indexed number, address indexed caller);
}