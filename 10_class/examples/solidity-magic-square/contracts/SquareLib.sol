// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

library SquareLib {
    
    struct MagicSquare {
        uint256[][] rows;
        uint256 n;
    }

    function initialize(uint256 _n)
        external
        pure
        returns (MagicSquare memory square)
    {
        square = MagicSquare({rows: new uint256[][](_n), n: _n});
        for (uint256 _i = 0; _i < _n; _i++) {
            square.rows[_i] = new uint256[](_n); // initialize each row with _n number of columns
        }
    }

    function step(
        MagicSquare memory square,
        uint256 _x,
        uint256 _y,
        uint256 _i
    )
        internal
        pure
        returns (
            uint256 _newX,
            uint256 _newY,
            uint256 _newI
        )
    {
        if (square.rows[_x][_y] != 0) {
            _newX = (_x + 2) % square.n;
            _newY = (square.n + _y - 1) % square.n;
            _newI = _i - 1;
        } else {
            square.rows[_x][_y] = _i;
            _newX = (square.n + _x - 1) % square.n;
            _newY = (_y + 1) % square.n;
            _newI = _i;
        }
    }
}