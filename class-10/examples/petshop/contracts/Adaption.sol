// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract Adoption {

    address[16] private _adopters;
    
    function adopt(uint _petId) public returns (uint) {
        require(_petId >= 0 && _petId <= 15);

        _adopters[_petId] = msg.sender;

        return _petId;       
    }

    function getAdopter(uint _petId) public view returns (address) {
        return _adopters[_petId];
    } 

    function getAdopters() public view returns (address[16] memory) {
        return _adopters;
    }
}