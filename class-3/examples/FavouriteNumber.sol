// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract FavouriteNumber {
    struct Person {
        string name;
        uint256 age;
        uint256 number;
        uint256 index;
    }

    mapping(address => Person) favouriteNumber;
    address[] public addressIndexes;

    function setMyFavouriteNumber(
        string memory _name,
        uint256 _age,
        uint256 _number
    ) public {
        require(
            isNewPerson(msg.sender),
            "favouriteNumber: Person cannot modify the number"
        );
        favouriteNumber[msg.sender].name = _name;
        favouriteNumber[msg.sender].age = _age;
        favouriteNumber[msg.sender].number = _number;
        addressIndexes.push(msg.sender);
        favouriteNumber[msg.sender].index = addressIndexes.length - 1;
    }

    function isNewPerson(address personAddress) internal view returns (bool) {
        if (addressIndexes.length == 0) {
            return true;
        }
        return (addressIndexes[favouriteNumber[personAddress].index] !=
            personAddress);
    }

    function getMyFavouriteNumber() public view returns (uint256) {
        return favouriteNumber[msg.sender].number;
    }
}
