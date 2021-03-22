// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface PriceFeed {
  function getPrice() external view returns (uint);
}

contract feed is PriceFeed {
      uint private _price = 42;
    function getPrice() public view override returns (uint) {
    return _price;
  }
}
 
contract Consumer {
  function callFeed(feed _feed) public view returns(uint) {
    return _feed.getPrice();
  }
}
