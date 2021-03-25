// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Game {
    
    address payable public currentLeader;
    uint    public highestBid;
    
    receive () external payable {
        require( msg.value > highestBid, "Bid is too low" );
        address payable oldLeader = currentLeader;
        uint refundAmount = highestBid;
        
        currentLeader = msg.sender;
        highestBid = msg.value;
        oldLeader.transfer(refundAmount);
    }
}

contract Attacker {
    function bid(address game) public payable {
        (bool success, ) = game.call{value:msg.value}("");
        require(success);
    }
    
    receive() external payable {
        revert();
    }
}

contract SafeGame {

    address payable public currentLeader;
    uint public highestBid;
    mapping(address => uint) refunds;

    receive () external payable {
        require(msg.sender != currentLeader, "must be different user");
        require(msg.value > highestBid, "Bid is too low");

        if(currentLeader != address(0)){
            refunds[currentLeader] += highestBid;
        }
        currentLeader = msg.sender;
        highestBid = msg.value;
    }
    
    function withdrowRefund() public payable{
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value:refund}("");
        require(success);
    }
}