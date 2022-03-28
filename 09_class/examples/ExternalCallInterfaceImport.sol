// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./IPriceFeed.sol";
 
contract ConsumerV1 {
  function callFeed(address _priceFeed) public view returns(uint) {
    return IPriceFeed(_priceFeed).getPrice();
  }
}
