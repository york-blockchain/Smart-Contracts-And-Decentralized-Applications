// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract TestBlockminer {
    
    function getCoinbase() public view returns(address){
        return block.coinbase;
    }
}