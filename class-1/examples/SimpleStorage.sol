// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract SimpleStorage {
    // state variable
    uint storedData; // 0 to (2^256 - 1), uint8,uint16,uint32 ... uint256 = uint
    
    // declare event
    event Increment(uint storedData, uint incrementValue);
    event Decrement(uint storedData, uint decrementValue);
        
    function set(uint _x) public {
        storedData = _x;
    }
    
    function get() public view returns(uint) {
        return storedData;
    }
    
    function increment(uint8 _n) public {
        storedData += uint256(_n);
        emit Increment(storedData, _n);
    }
    
    function decrement(uint _n) public {
        storedData -= _n;
        emit Decrement(storedData, _n);
    }
}