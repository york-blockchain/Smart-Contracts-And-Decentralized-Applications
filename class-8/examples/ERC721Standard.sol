// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";

contract ERC721Standard is IERC721,IERC721Metadata, IERC721Enumerable {
    
    mapping(address => uint256[]) private _holderToTokens;
    
    mapping(uint256 => address) private _tokenIdToHolder;
    
    mapping(uint256 => address) private _tokenApprovals;
    
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    uint256[] private _tokenIDs;
    
    mapping(uint256 => uint256) private _tokenIDToTokenIndex;
    
    string private _name;
    
    string private _symbol;
    
    mapping(uint256 => string) private _tokenURIs;
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    
    // optional
    string private _baseURI;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view override returns (string memory) {
        return _name;
    }
    
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    
    function totalSupply() public view override returns(uint256) {
        return _tokenIDs.length;
    }
    
    function baseURI() public view returns(string memory) {
        return _baseURI;
    }
    
    function setBaseURI(string memory baseURI_) public  {
        _baseURI = baseURI_;
    }
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view override returns(uint256 tokenId) {
        uint256 _tokenId = _holderToTokens[_owner][_index];
        return _tokenIDToTokenIndex[_tokenId];
    }

    function getTokenIndexByTokenID(uint256 _tokenId) public view returns (uint256) {
        return _tokenIDToTokenIndex[_tokenId];
    }
    
    function tokenByIndex(uint256 _index) public view override returns(uint256) {
        return _tokenIDs[_index];
    }

    function balanceOf(address _owner) public override view returns (uint256) {
        require(_owner != address(0), "ERC721 : balance query for zero address");
        return _holderToTokens[_owner].length;
    }
    
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId),"ERC721: approved query for nonexistant token");
        string memory _tokenURI = _tokenURIs[_tokenId];
        
        if(bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI,_tokenURI));
        }
        
        return string(abi.encodePacked(_baseURI, _toString(_tokenId)));
    }
    
    function _toString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        
        uint256 _digits;
        uint256 _temp = _value;
        while(_temp != 0) {
            _digits++;
            _temp /= 10;
        }
        
        bytes memory buffer = new bytes(_digits);
        uint256 index = _digits - 1;
        _temp = _value;
        
        while(_temp != 0) {
            buffer[index--] = byte(uint8(48 + _temp % 10));
            _temp /= 10;
        }
        
        return string(buffer);
    }
    
    function ownerOf(uint256 _tokenId) public override view returns (address) {
        require(_exists(_tokenId),"ERC721: approved query for nonexistant token");
        return _tokenIdToHolder[_tokenId];
    }
    
    function approve(address _operator, uint256 _tokenId) public override payable {
        require(_exists(_tokenId),"ERC721: approved query for nonexistant token");
        address _owner = _tokenIdToHolder[_tokenId];
        require(_owner == msg.sender, "ERC721: approve caller is not owner nor approved for all");
        require(_owner != _operator, "ERC721: approval to current owner");
        _tokenApprovals[_tokenId] = _operator;
        emit Approval(_owner, _operator, _tokenId);
    }
    
    function getApproved(uint256 _tokenId) public override view returns (address) {
        require(_exists(_tokenId),"ERC721: approved query for nonexistant token");
        return _tokenApprovals[_tokenId];    
    }
    
    function setApprovalForAll(address _operator, bool _approved) public override {
        require(_operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function isApprovedForAll(address _owner, address _operator) public override view returns (bool) {
        return _operatorApprovals[_owner][_operator];   
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public override payable {
        require(_exists(_tokenId),"ERC721: approved query for nonexistant token");
        // msg.sender should be approved
        address _owner = _tokenIdToHolder[_tokenId];
        address _spender = msg.sender;
        bool _isApprovedOrOwner = (_owner  == _spender || getApproved(_tokenId) == _spender || isApprovedForAll(_owner, _spender));
        require(_isApprovedOrOwner, "ERC721: transfer caller is not owner nor approved");
        
        require(_owner == _from, "ERC721: transfer of token that is not own");
        require(_to != address(0), "ERC721: transfer to the zero address");
        
        // clear approvals from previous owner
        approve(address(0), _tokenId);
        
        // remove _from from _holderToTokens
        uint8 _len = uint8(balanceOf(_from));
        for(uint8 _i = 0 ; _i < _len ; _i++) {
            if(_holderToTokens[_from][_i] == _tokenId) {
                delete _holderToTokens[_from][_i];
            }            
        }
        
        // add _to from _holderToTokens
        _holderToTokens[_to].push(_tokenId);
        
        // emit event
        emit Transfer(_from, _to, _tokenId);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override payable {
        transferFrom(_from,  _to,  _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data));
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override payable {
        transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, ""));
    }
    
    function safeMint(address _to, uint256 _tokenId) public {
        mint(_to, _tokenId);
        require(_checkOnERC721Received(address(0), _to, _tokenId, ""));
    }
    
    function safeMint(address _to, uint256 _tokenId, bytes memory data) public {
        mint(_to, _tokenId);
        require(_checkOnERC721Received(address(0), _to, _tokenId, data));
    }
    
    function mint(address _to, uint256 _tokenId) public {
        require(_to != address(0), "ERC721: mint to the zero address");
        require(!_exists(_tokenId),"ERC721: approved query for nonexistant token");
        
        _tokenIdToHolder[_tokenId] = _to;
        _holderToTokens[_to].push(_tokenId);
        
        _tokenIDs.push(_tokenId);
        uint _index = _tokenIDs.length - 1;
        _tokenIDToTokenIndex[_tokenId] = _index;
        
        emit Transfer(address(0), _to, _tokenId);
    }
    
    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) private returns (bool) {
        if (!isContract(_to)) {
            return true;
        }
        
        (bool _success, bytes memory _returnData) = _to.call(
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)", msg.sender, _from, _tokenId, _data));
        require(_success,"low-level-failed");
        bytes4 _retVal = abi.decode(_returnData, (bytes4));
        return (_retVal == _ERC721_RECEIVED);
    }
    
    function _exists(uint256 _tokenId) internal view returns(bool) {
        if(_tokenIDs.length == 0) {
            return false;
        }
        
        return (_tokenIDs[_tokenIDToTokenIndex[_tokenId]] == _tokenId);
    }
    
    function isContract(address _account) internal view returns (bool) {
        uint256 _size;
        assembly { _size := extcodesize(_account)}
        return _size > 0;
    }
    
}
