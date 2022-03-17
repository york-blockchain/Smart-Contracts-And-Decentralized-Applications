// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

library ConvertLib {
    function convert(uint _amount, uint _conversionRate) internal pure returns(uint) {
        return _amount * _conversionRate;
    }
}