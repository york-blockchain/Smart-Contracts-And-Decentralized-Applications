// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

contract GeneralStruct {
    struct myStruct {
        uint8 myAge;
        bool isMarried;
        string name;
        address[] accounts;
    }

    mapping(address => myStruct) public myMapping;

    function setMyStruct(
        string memory _name,
        uint8 _myAge,
        bool _isMarried,
        address[] memory _accounts
    ) public {
        for (uint8 i = 0; i < _accounts.length; i++) {
            myMapping[msg.sender].accounts.push(_accounts[i]);
        }
        myMapping[msg.sender].name = _name;
        myMapping[msg.sender].myAge = _myAge;
        myMapping[msg.sender].isMarried = _isMarried;
    }

    function setMyStructFromArg(myStruct memory _myStruct) public {
        myMapping[msg.sender] = _myStruct;
    }

    function getMyStruct(address _personIdentifier)
        public
        view
        returns (
            string memory _name,
            uint8 _myAge,
            bool _isMarried,
            address[] memory _accounts
        )
    {
        _name = myMapping[_personIdentifier].name;
        _myAge = myMapping[_personIdentifier].myAge;
        _isMarried = myMapping[_personIdentifier].isMarried;
        _accounts = myMapping[_personIdentifier].accounts;
    }

    function getMyStructWithMultipleReturn(address _personIdentifier)
        public
        view
        returns (
            string memory,
            uint8,
            bool
        )
    {
        string memory _name = myMapping[_personIdentifier].name;
        uint8 _myAge = myMapping[_personIdentifier].myAge;
        bool _isMarried = myMapping[_personIdentifier].isMarried;
        return (_name, _myAge, _isMarried);
    }

    function getMyStructWithABIEncoderV2(address _personIdentifier)
        public
        view
        returns (myStruct memory)
    {
        return myMapping[_personIdentifier];
    }
}
