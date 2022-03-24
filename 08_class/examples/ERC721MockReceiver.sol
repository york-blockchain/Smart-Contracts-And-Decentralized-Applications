// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./IERC721Receiver.sol";

contract ERC721MockReceiver is IERC721Receiver {
    bytes4 private _retVal;
    
    bool private _revert;
    
    event Received(address _operator, address _from, uint256 _tokenId, bytes data, uint256 gas);
    
    constructor(bytes4 retVal_, bool revert_) {
        _retVal = retVal_;
        _revert = revert_;
    }
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) public override returns (bytes4) {
        require(!_revert,"ERC721MockReceiver: reverting");
        emit Received(_operator, _from, _tokenId, _data, gasleft());
        return _retVal;
    }
}