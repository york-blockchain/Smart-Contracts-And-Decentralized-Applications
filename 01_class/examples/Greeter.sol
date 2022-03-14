// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract Greeter {
    // state variables
    string public yourName; // contract storage

    function set(string memory _name) public {
        yourName = _name;    
    }
    
    function hello() public view returns(string memory) {
        return yourName;
    }
}
