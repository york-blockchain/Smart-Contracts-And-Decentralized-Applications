// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./ExternalCall.sol";
 
contract ConsumerV2 {

    PriceFeed public priceFeedContract;

    constructor (address _priceFeed) {
        priceFeedContract = PriceFeed(_priceFeed); 
    }    
    
  function callFeed() public view returns(uint) {
    return priceFeedContract.getPrice();
  }
}