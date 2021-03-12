// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

interface IHelloWorld { // interface functions are virtual by default
    function setValue(uint) external; 
    function getValue() external view returns(uint);
} 

contract HelloWorld is IHelloWorld {
    uint simpleInt;
    
    function setValue(uint _val) public override {
        simpleInt = _val;
    } 
    function getValue() public view override returns(uint) {
        return simpleInt;
    }
}

contract Client {
    address helloWorld;
    
    constructor(address _helloWorld) {
        helloWorld = _helloWorld;
    }
    
    function setValueViaIHelloWorld(uint _val) public {
        IHelloWorld(helloWorld).setValue(_val);
    }
    
    function getValueViaIHelloWorld() public view returns(uint) {
        return IHelloWorld(helloWorld).getValue();
    }
}