/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.21 <0.7.0;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

contract TokenSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    address owner;

    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

     constructor(IERC20Token _tokenContract, uint256 _price) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
    }

    function buyTokens(uint256 numberOfTokens) public payable {
        require(msg.value == numberOfTokens * price);

        uint256 scaledAmount = numberOfTokens *
            (uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(address(this)) >= scaledAmount);

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function endSale() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));

        // Destroy this contract, sending all collected ether to the owner.
        selfdestruct(address(uint160(owner)));
    }
}