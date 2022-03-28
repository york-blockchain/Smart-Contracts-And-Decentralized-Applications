// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

// realizing ABI of PriceFeed contract
interface IPriceFeed {
  function getPrice() external view returns (uint);
}