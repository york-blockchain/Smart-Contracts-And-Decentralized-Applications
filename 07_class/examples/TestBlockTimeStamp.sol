// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract TestBlockTimestamp {
    
    function getTime() public view returns(uint){
        return block.timestamp;
    }
}