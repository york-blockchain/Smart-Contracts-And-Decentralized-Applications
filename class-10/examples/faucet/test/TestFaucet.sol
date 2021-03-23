// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Faucet.sol";

contract TestFaucet {

    // Truffle will send the TestContract one Ether after deploying the contract.
  uint public initialBalance = 10000000 wei;
    Faucet faucet;
    function testInitialBalanceUsingDeployedContract() public {
        // uint amount = 1 ether;
        faucet = Faucet(DeployedAddresses.Faucet());
        // perform an action which sends value to myContract, then assert.
        address(faucet).transfer(initialBalance);
        Assert.equal(address(faucet).balance,initialBalance,"Balance is zero");
        // (bool result, ) = address(faucet).call(abi.encodePacked("withdraw(uint)", amount));
        // Assert.equal(result, false, "Allows for withdrawal");
    }

    // function testWithdrawal() public {
    //     uint amount = 10 ether;
    //     faucet = Faucet(DeployedAddresses.Faucet());
    //     (bool result, ) = address(faucet).call(abi.encodePacked("withdraw(uint)", amount));
    //     Assert.equal(result, false, "Allows for withdrawal");
    // }
    
}