// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract CustomModifierDemo {
    
    address public owner;
    uint public data;
    
    constructor() public {
        owner = msg.sender; // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    }
    
    /*
    modifier name_of_modifier (<parameter>) {
        if(msg.sender != owner){
            revert();
        }
        _;
    }
    */
    

    modifier onlyOwner(uint _data) {
        if(msg.sender != owner || _data <= 0){
            revert();
        }
        _; // underscore
    }
    
    function setData(uint _data) public onlyOwner( _data) {
        data = _data;
    }
    
    
    /*
    function setData(uint _data) public {
        if(msg.sender != owner) {
            revert();
        }
        data = _data;
    }
    */
    
}