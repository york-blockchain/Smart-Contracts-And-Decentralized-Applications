// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract Token {
    
    mapping(address => uint) public balances;
    address public owner;
    uint public startTime;
    
    constructor(uint _totalSupply) public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        startTime = block.timestamp;
    }
    
    modifier onlyIfBalance(uint _amount) {
        require(balances[msg.sender] > _amount,"insufficient balance");
        _;
    }
    
    function transferToken(address _to, uint _amount) public onlyIfBalance(_amount) {
        if(msg.sender == owner && block.timestamp >= startTime + 10 seconds){
            balances[msg.sender] = balances[msg.sender] - _amount;
            balances[_to] = balances[_to] + _amount;
        }
        else {
            revert("TIme not elapsed yet");
        }
    }
    
    function getBalance(address _holder) public view returns(uint) {
        return balances[_holder];
    } 
}