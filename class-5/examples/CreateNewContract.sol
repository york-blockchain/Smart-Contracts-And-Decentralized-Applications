// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract HelloWorld {
    uint simpleInt; 
    // uint private simpleInt;
    
    function getSimpleInt() public view returns(uint) {
        return simpleInt;
    }
    
    function setSimpleInt(uint _simpleInt) public {
        simpleInt = _simpleInt;
    }
}

contract Client {
    
    HelloWorld myObj;
    
    constructor() {
        myObj = new HelloWorld();
    }
    
    function getMyobj() public view returns(address) {
        return address(myObj);
    }
    
    function setNumber(uint _number) public {
        myObj.setSimpleInt(_number);
    }
    
    function getNumber() public view returns(uint) {
        return myObj.getSimpleInt();
    }
}