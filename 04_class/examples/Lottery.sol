// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

import “./Ownable.sol”;

// Lottery game contract starts here
contract Lottery is Ownable {
    //variable to cater player attribute
    struct Player {
        string name;
        uint256 entryCount;
        uint256 index;
    }

    // declaration related to player starts here
    // map account address of `players` to their names
    mapping(address => Player) public players;
    // record unique address of player
    address[] public addressIndexes;
    // declare an array to keep record of sold tickets
    address[] public lotteryTickets;

    // let us allow the user to participate in the lottery game
    // by calling the `enter` function. The user can supply
    // name (a string). Notice that string being reference is
    // required to specify data location i.e. memory
    function enter(string memory _name) public {
        // let us not allow manager to participate in the game
        require(
            owner() != msg.sender,
            "Lottery: Manager cannot enter in the game"
        );
        // it is required to always have a uniqueness check adhering to game rules
        if (isNewPlayer(msg.sender)) {
            // assign the name of the participant against the
            // participant’s account address
            players[msg.sender].name = _name;
            // assign the number of tickets that participant possesses
            players[msg.sender].entryCount = 1;
            // appending address of player to addressIndexes array
            addressIndexes.push(msg.sender);
            // assign the location of player in addressIndexes array
            // to the player's index
            players[msg.sender].index = addressIndexes.length - 1;
        } else {
            // if player is already enter once, increase entryCount by 1
            players[msg.sender].entryCount += 1;
        }
        // add a lottery to `lotteryTickets` array
        lotteryTickets.push(msg.sender);
    }

    // Private functions to check player's address uniqueness
    function isNewPlayer(address playerAddress) private view returns (bool) {
        if (addressIndexes.length == 0) {
            return true;
        }
        return (addressIndexes[players[playerAddress].index] != playerAddress);
    }

    // the function `pickWinner` will perform draw to determine
    // the winner. Here we are returning the address and name of the winner that is why we have address and string respectively.
    function pickWinner() public view returns (address, string memory) {
        // we will not allow anyone except the manager to
        // determine winner
        if (msg.sender != owner()) {
            // throw to the caller if she is not the manager
            revert("Lottery: Only Manager can call draw");
        }
        // calculate the random number and assign it to
        // `_winner`. The winner has to be index equal to
        // number of lottery tickets sold hence we are
        // computing the modulus of random number generator
        uint256 _winner = generateRandomNumber() % lotteryTickets.length;
        // it returns address and name of the of the winner
        return (lotteryTickets[_winner], players[lotteryTickets[_winner]].name);
    }

    // NOTE: Do not use this code in the real world.
    // visit https://ethereum.stackexchange.com/a/207 to know
    // security trade offs that it may produce
    function generateRandomNumber() private view returns (uint256) {
        // you can directly return the evaluated value like
        // javascript
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        now,
                        lotteryTickets.length
                    )
                )
            );
    }
}
