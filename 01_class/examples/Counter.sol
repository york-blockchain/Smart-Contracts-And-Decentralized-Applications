// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract Counter {
    
    event ValueChanged(uint indexed oldValue, uint256 indexed newValue);
    
    // tracks the number of counts
    uint256 count = 0;

    // Function that increments counter
    function increment() public {
        count += 1;
        emit ValueChanged(count - 1, count);
    }
    
    // Getter function to get the count value
    function getCount() public view returns (uint256) {
        return count;
    }
}