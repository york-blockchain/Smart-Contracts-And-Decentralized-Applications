// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Adaption.sol";

contract TestAdoption {
    // get the deployed contract address
    Adoption adoption = Adoption(DeployedAddresses.Adoption());

    uint expectedPetId = 8;

    address expectedAdopter = address(this);

    function testUserCanAdoptPet() public {
        uint returnedPetId = adoption.adopt(expectedPetId);

        Assert.equal(returnedPetId, expectedPetId, "Adoption of the expected pet should match what is returned");
    }

    function testGetAdopterAddressByPetId() public {
        address adopter = adoption.getAdopter(expectedPetId);

        Assert.equal(adopter, expectedAdopter, "Owner of the expected pet should be this contract");
    }

    function testGetAdopters() public {
        address[16] memory adopters = adoption.getAdopters();

        Assert.equal(adopters[expectedPetId], expectedAdopter, "Owner of the expected pet should be this contract");
    }
}