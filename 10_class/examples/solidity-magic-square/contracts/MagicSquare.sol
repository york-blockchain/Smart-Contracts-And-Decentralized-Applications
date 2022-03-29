// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./SquareLib.sol";

contract MagicSquare {
    
    using SquareLib for SquareLib.MagicSquare;

    SquareLib.MagicSquare storedSquare;

    function generateMagicSquare(uint _n) public {
        SquareLib.MagicSquare memory square;
        square = SquareLib.initialize(_n);

        uint _x = 0;
        uint _y = _n / 2;
        for(uint _i = 1 ; _i <= _n * _n ; _i++) {
         (_x, _y, _i) = square.step(_x , _y , _i );
        }
        this.save(square);
    }

    function getSquare() public view returns (SquareLib.MagicSquare memory) {
        return storedSquare;
    }

    function save(SquareLib.MagicSquare memory square) public {
        storedSquare.n = square.n;
        storedSquare.rows = new uint[][](square.n);
        for (uint _i = 0 ; _i < square.n ; _i++) {
            storedSquare.rows[_i] = new uint[](square.n);
            for(uint _j = 0 ; _j < square.n ; _j++) {
                storedSquare.rows[_i][_j] = square.rows[_i][_j];
            }
        }
    }
}