// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

abstract contract A {
    uint public x;
    
    constructor(uint _x) {
        x = _x;
    }
}

// values needs to be determined during runt time.
contract B is A {
    constructor(uint _x) A(_x) {}
}

// values to parent contract are pre-defined during compile time
contract C is A(1) {
}