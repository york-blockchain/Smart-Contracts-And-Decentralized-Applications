// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

struct Data {
    uint256 a;
    uint256 b;
}

contract TestMappingDelete {
    mapping(uint256 => Data) public items;

    function MyContract() public {
        items[0] = Data(1, 2);
        items[1] = Data(3, 4);
        items[2] = Data(5, 6);
        delete items[1];
    }
}
