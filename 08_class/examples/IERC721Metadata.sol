// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

interface IERC721Metadata {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function tokenURI(uint256 _tokenId) external view returns (string memory);
}