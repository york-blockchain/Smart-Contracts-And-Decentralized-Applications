//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface ILib {
    function version() external view returns(uint);
}

contract LibV1 is ILib {
    uint public override version = 1;
}

contract Ownable {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "not onwer!");
        _;
    }
}

contract Proxy is Ownable {
    ILib public lib;
    constructor(ILib libAddress) public {
        lib = libAddress;
    }
    function upgrade(ILib newLib) public onlyOwner {
        lib = newLib;
    }
    function version() public view returns(uint) {
        return lib.version();
    }
}