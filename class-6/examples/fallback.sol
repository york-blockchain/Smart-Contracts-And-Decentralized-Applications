// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

contract Fallback {
    event Log(uint gas);

    mapping(address => bool) public blacklist;

    // Fallback function must be declared as external.
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        blacklist[msg.sender] = true;
        emit Log(gasleft());
    }

    modifier onlyWhiteListed() {
        require(!blacklist[msg.sender], "no no");
        _;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view onlyWhiteListed returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}