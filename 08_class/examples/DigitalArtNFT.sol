// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./ERC721Standard.sol";

contract DigitalArtNFT is ERC721Standard {
    
    uint256 public pendingArtCount;
    
    struct Art {
        uint256 id;
        string title;
        string description;
        uint256 price;
        string date;
        string authorName;
        address payable author;
        address payable owner;
        SoldStatus status;
        string image;
    }
    
    enum SoldStatus {FOR_SALE, SOLD}
    
    Art[] public arts;
    
    constructor(string memory _name, string memory _symbol) ERC721Standard(_name,_symbol) {
        
    }
    
    function createTokenAndSellArt(
        string memory _title, 
        string memory _description, 
        string memory _date, 
        string memory _authorName,
        uint256 _price, 
        string memory _image
        ) public {
            require(bytes(_title).length > 0, 'The title cannot be empty');
            require(bytes(_description).length > 0, 'The description cannot be empty');
            require(bytes(_date).length > 0, 'The date cannot be empty');
            require(bytes(_authorName).length > 0, 'The authorName cannot be empty');
            require(_price > 0 , 'The price cannot be zero');
            require(bytes(_image).length > 0, 'The image cannot be empty');
            
            Art memory _art = Art ({
                id : 0,
                title : _title,
                description: _description,
                price : _price,
                date : _date,
                authorName : _authorName,
                author : msg.sender,
                owner : msg.sender,
                status: SoldStatus.FOR_SALE,
                image : _image
            });
            arts.push(_art);
            uint256 _tokenId = arts.length - 1;
            safeMint(msg.sender, _tokenId);
            uint _index = getTokenIndexByTokenID(_tokenId);
            arts[_index].id = _index;
            pendingArtCount++;
        }
        
        function buyArt(uint256 _tokenId) payable public {
            require(!_exists(_tokenId),"nonexistant token");
            uint _index = getTokenIndexByTokenID(_tokenId);
            Art memory _art = arts[_index];
            require(msg.value >= _art.price);
            require(msg.sender != address(0));
            
            if (msg.value > _art.price) {
                msg.sender.transfer(msg.value - _art.price);
            }
            _art.owner.transfer(_art.price);
            transferFrom(_art.owner, msg.sender, _tokenId);
            arts[_index].owner = msg.sender;
            arts[_index].status = SoldStatus.SOLD;
            pendingArtCount--;
        }
        
        function resellArt(uint256 _tokenId, uint256 _price) payable public {
            require(msg.sender != address(0));
            require(_price > 0);
            address _owner = ownerOf(_tokenId);
            require(msg.sender == _owner);
            uint _index = getTokenIndexByTokenID(_tokenId);
            arts[_index].status = SoldStatus.FOR_SALE;
            arts[_index].price = _price;
            pendingArtCount++;
        }
}