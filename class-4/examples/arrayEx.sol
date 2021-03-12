// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract arrayExample {
    // dynamic length array
    bytes32[] public names;
    
    // fixed length array
    bytes[4] public fNames;
    
    function arrTest() public returns (uint){
        // assign inline
        string[4] memory _inlineArray = ["sam","mike","peter","mckay"];
        
        // multi dimensional array
        uint[3][] memory multiArray;
        
        fNames[0] = "Matt";
        
        names.push("JON");
        names.push("PURDY");
        
        // intialize the multi dimensional array
        multiArray = new uint[3][](2); // number of rows = 2
        
        // multiArray[0][1] = 20;

        // return multiArray[0][1];
    }
    
}