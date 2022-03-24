// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

interface IERC721Enumerable {
 function totalSupply() external view returns(uint256);
 function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns(uint256 tokenId);
 function tokenByIndex(uint256 _index) external view returns(uint256);
}