// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract ReturnValues {
    uint256 counter;

    function SetNumber() {
        counter = block.number;
    }

    function getBlockNumber() returns (uint256) {
        return counter;
    }

    function getBlockNumber1() returns (uint256 result) {
        result = counter;
    }
}
