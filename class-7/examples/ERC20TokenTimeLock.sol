// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "./IERC20.sol";

contract TokenTimeLock {
    
    IERC20 private _token;
    address private _beneficiary;
    uint256 private _releaseTime;
    
    constructor(IERC20 _token_, address _beneficiary_, uint256 _releaseTime_) {
        _token = _token_;
        _beneficiary = _beneficiary_;
        _releaseTime = block.timestamp + _releaseTime_;
    }
    
    function token() public view returns(IERC20) {
        return _token;
    }
    
    function beneficiary() public view returns(address) {
        return _beneficiary;
    }
    
    function releaseTime() public view returns(uint256) {
        return _releaseTime;
    }
    
    function release() public {
        require(block.timestamp >= _releaseTime, "TokenTimeLock: current time is before release time");
        uint256 _amount = _token.balanceOf(address(this));
        require(_amount > 0, "TokenTimeLock:Empty balance");
        _token.transfer(_beneficiary, _amount);
        selfdestruct(payable(_beneficiary));
    }
}

contract TokenSaleWithTimeLock {
    
    IERC20 public tokenContract;
    uint256 public price;
    uint256 public tokensSold;
    uint256 public releaseTime;
    
    event Sold(address indexed buyer, address indexed timelock, uint256 amount);
    
    address public owner;
    
    constructor(IERC20 _tokenContract, uint256 _price, uint256 _releaseTime) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
        releaseTime = _releaseTime;
    }
    
    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens * price);
        
        uint256 _scaledAmount = _numberOfTokens * (10**tokenContract.decimals());
        
        require(tokenContract.balanceOf(address(this)) >= _scaledAmount);
        // require(tokenContract.transfer(msg.sender, _scaledAmount));
        
        TokenTimeLock _tokenTimeLock = new TokenTimeLock(tokenContract, msg.sender, 60);
        require(tokenContract.transfer(address(_tokenTimeLock), _scaledAmount));
        tokensSold += _scaledAmount;
        emit Sold(msg.sender, address(_tokenTimeLock), _scaledAmount);
    }
    
    function endSale() public {
        require(msg.sender == owner,"restricted access");
        uint256 _amount = tokenContract.balanceOf(address(this));
        
        // Sending unsold tokens to the owner
        require(tokenContract.transfer(msg.sender, _amount));
        
        // destroy , send the balance of ether from this contract
        selfdestruct(payable(owner));
    }
    
}