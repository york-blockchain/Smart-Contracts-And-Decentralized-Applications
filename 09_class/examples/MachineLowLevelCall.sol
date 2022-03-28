// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Calculator {
    uint256 public calculateResult;
    
    address public user;
    
    event Add(uint256 a, uint256 b);
    
    function add(uint256 a, uint256 b) public returns (uint256) {
        calculateResult = a + b;
        assert(calculateResult >= a);
        
        emit Add(a, b);
        user = msg.sender;
        
        return calculateResult;
    }
}

contract Machine {
    uint256 public calculateResult;
    
    address public user;
    
    event AddedValuesByDelegateCall(uint256 a, uint256 b, bool success);
    event AddedValuesByCall(uint256 a, uint256 b, bool success);
    
    constructor() public {
        calculateResult = 0;
    }
    
    function addValuesWithDelegateCall(address calculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = calculator.delegatecall(abi.encodeWithSignature("add(uint256,uint256)", a, b));
        emit AddedValuesByDelegateCall(a, b, success);
        return abi.decode(result, (uint256));
    }
    
    function addValuesWithCall(address calculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = calculator.call(abi.encodeWithSignature("add(uint256,uint256)", a, b));
        emit AddedValuesByCall(a, b, success);
        return abi.decode(result, (uint256));
    }
    
    // This function will fail as there is a state change in target contract
    function addValuesWithStaticCall(address calculator, uint256 a, uint256 b) public returns (uint256) {
        (bool success, bytes memory result) = calculator.staticcall(abi.encodeWithSignature("add(uint256,uint256)", a, b));
        emit AddedValuesByCall(a, b, success);
        return abi.decode(result, (uint256));
    }
    
    // This function reads from target contract
    function getCalculateResultWithStaticCall(address calculator) public view returns (uint256) {
        (bool success, bytes memory result) = calculator.staticcall(abi.encodeWithSignature("calculateResult()"));
        require(success);
        return abi.decode(result, (uint256));
    }
}