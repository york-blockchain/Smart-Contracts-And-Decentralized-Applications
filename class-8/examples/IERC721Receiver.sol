// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

interface IERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata data) external returns (bytes4);
}