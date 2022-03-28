// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract ReceiveEther {

    uint public i = 0;
    
    /* fallback() or receive()?
       send Ether
           \
         msg.data is empty?
                /         \
             yes           no
             /               \
       receive() exists?  fallback()
           /      \
          yes     no
          /        \
       receive()  fallback()
     */
    
    // function to receive Ether. msg.data is empty
    receive() external payable {}
    
    // msg.data is not empty
    fallback() external payable {
        i++;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendEther {
    // sending via `transfer`
    function sendViaTransfer(address payable _receiver) public payable { // _receiver can be an EOA or a contract
        _receiver.transfer(msg.value);
    }
    
    // sending via `send`
    function sendViaSend(address payable _receiver) public payable { // _receiver can be an EOA or a contract
        bool _success = _receiver.send(msg.value);
        require(_success, "Ether transfer failed");
    }
    
    function sendViaCall(address payable _receiver) public payable { 
        // recommend
        (bool _success, bytes memory data) = _receiver.call{value:msg.value}(""); // low-level call
        require(_success,"Ether transfer failed");
    }
}