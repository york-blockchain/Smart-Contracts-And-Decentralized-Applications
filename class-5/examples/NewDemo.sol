// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract tokenContract {
    uint public balance;
} 

contract Exchange {
  address _token;
  constructor (address token) public { _token = token;}
}
 
contract Factory {
  mapping (address => address) public tokenToExchange;
  function createExchange(address token) public {
    Exchange exchange = new Exchange(token);
    tokenToExchange[token] = address(exchange);
  }
}