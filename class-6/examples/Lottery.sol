// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

import "./Ownable.sol";

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
    // declare a boolean variable to activate Lottery game
    bool public isLotteryLive;
    // declare an uint type variable to set the game
    // participation fee
    uint256 public ethToParticipate;
    // a variable to limit to number of tickets per participant
    uint256 public maxEntriesForPlayers;
    // a variable to store lottery name
    string public lotteryName;
    // manager of the lottery
    address public owner;
    // declare a variable to store winner
    Player public winner;

    modifier onlyOwner() {
        require(owner == msg.sender, "lottery: caller is not the owner");
        _;
    }

    constructor(string memory _lotteryName, address _owner) public {
        lotteryName = _lotteryName;
        owner = _owner;
    }

    receive() external payable {
        enter("unknown");
    }

    // let us allow the user to participate in the lottery game
    // by calling the `enter` function. The user can supply
    // name (a string). Notice that string being reference is
    // required to specify data location i.e. memory
    function enter(string memory _name) public payable {
        // let us not allow manager to participate in the game
        require(
            this.owner() != msg.sender,
            "Lottery: Manager cannot enter in the game"
        );
        // only execute further if game is activated
        require(isLotteryLive);
        // the player must pay required fee to play Lottery
        require(msg.value == ethToParticipate);
        // do not let player buy lottery tickets beyond maxEntriesForPlayers
        require(players[msg.sender].entryCount < maxEntriesForPlayers);
        // the name should not be an empty string
        require(bytes(_name).length > 0);
        // it is required to always have a uiqueness check adhering to game rules
        if (isNewPlayer(msg.sender)) {
            // assign the name of the participant against the
            // participant’s account address
            players[msg.sender].name = _name;
            // assign the number of tickets that participant posess
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

    function kickOffLottery(uint256 maxEntries, uint256 ethRequired)
        public
        onlyOwner
    {
        isLotteryLive = true;
        maxEntriesForPlayers = maxEntries == 0 ? 1 : maxEntries;
        ethToParticipate = ethRequired == 0 ? 1 ether : ethRequired;
    }

    // Private functions to check player's address uniqueness
    function isNewPlayer(address playerAddress) private view returns (bool) {
        if (addressIndexes.length == 0) {
            return true;
        }
        return (addressIndexes[players[playerAddress].index] != playerAddress);
    }

    // the function `pickWinner` will perform draw to determine
    // the winner.
    function pickWinner() public payable onlyOwner {
        // Check if the game is activated
        require(isLotteryLive, "Lottery: game is not live");
        // the lottery bag should be non-zero
        require(lotteryTickets.length > 0);
        // calculate the random number and assign it to
        // `_winner`. The winner has to be index equal to
        // number of lottery tickets sold hence we are
        // computing the modulus of random number generator
        uint256 _winnerIndex = generateRandomNumber() % lotteryTickets.length;
        winner.name = players[lotteryTickets[_winnerIndex]].name;
        winner.entryCount = players[lotteryTickets[_winnerIndex]].entryCount;

        payable(lotteryTickets[_winnerIndex]).transfer(address(this).balance);

        // empty the lottery bag and indexAddresses
        lotteryTickets = new address payable[](0);
        addressIndexes = new address[](0);

        // Mark the lottery inactive
        isLotteryLive = false;

        // reward the winner

        // event
        emit WinnerDetermined(winner.name, winner.entryCount);
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
                        block.timestamp,
                        lotteryTickets.length,
                        msg.sender,
                        address(this).balance,
                        block.number,
                        gasleft()
                    )
                )
            );
    }

    event WinnerDetermined(string indexed _name, uint256 indexed entryCount);
}

contract LotteryFactory {
    address[] public lotteries;

    struct lottery {
        uint256 index;
        address manager;
    }

    mapping(address => lottery) contractAddressToLottery;

    function createLottery(string memory name) public {
        require(bytes(name).length > 0);
        Lottery newLottery = new Lottery(name, msg.sender);
        lotteries.push(address(newLottery));
        contractAddressToLottery[address(newLottery)].index =
            lotteries.length -
            1;
        contractAddressToLottery[address(newLottery)].manager = msg.sender;
        // event
        emit LotteryCreated(address(newLottery));
    }

    function getLotteries() public view returns (address[] memory) {
        return lotteries;
    }

    // Events
    event LotteryCreated(address indexed lotteryContractAddress);
}
