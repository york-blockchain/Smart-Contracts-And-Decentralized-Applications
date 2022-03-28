// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract Consumer {
  function callFeed(address _feed) public returns(uint _price) {
    (bool _success, bytes memory _returnData) = _feed.call(abi.encodeWithSignature("getPrice()"));
    require(_success);
    (_price) = abi.decode(_returnData,(uint));
  }
}