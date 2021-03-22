// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract PriceFeed { 
  uint private _price = 42;
  function getPrice() public view returns (uint) {
    return _price;
  }
}
 
contract Consumer {
  function callFeed(PriceFeed feed) public view returns(uint) {
    return feed.getPrice();
  }
}
