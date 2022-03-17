// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <=0.6.0;

library GameLibrary {

    event TicketBought(uint256 _gameId, uint256 _ticketId, address indexed _player, bytes _numbers);

    struct Ticket {
        address player;
        uint256 buyTime;
        bytes numbers;
    }

    struct Game {
        uint256 uid;
        uint256 startTime;
        uint256 prizePool;
        bytes winningNumbers;
        // support get matched numbers count easier
        mapping(byte => bool) winningNumbersMap;
        mapping(uint256 => Ticket) tickets;
        address[] winners;
        uint256 ticketSeq;
        mapping(address => bytes32) secretHashes;
        uint256[] secretKeys;
        uint256 revealPhaseDeadline;
    }

    modifier validSignature(bytes32 _h, uint8 _v, bytes32 _r, bytes32 _s) {
        require(ecrecover(_h, _v, _r, _s) == msg.sender, "CryptoLottery: bad signature");
        _;
    }

    modifier validSecretKey(Game storage game, uint256 _secretKey) {
        bytes32 msgHash = keccak256(abi.encodePacked(this, game.uid, _secretKey));
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
        require(game.secretHashes[msg.sender] == prefixedHash, "CryptoLottery: invalid secret key");
        _;
    }

    modifier noDuplicates(bytes memory numbers) {
        for (uint256 i = 0; i < numbers.length - 1; i++) {
            for (uint256 j = i + 1; j < numbers.length; j++) {
                require(numbers[i] != numbers[j], "CryptoLottery: numbers duplicated");
            }
        }
        _;
    }

    modifier inRevealPeriod(Game storage game) {
        require(game.revealPhaseDeadline >= now, "CryptoLottery: too late");
        _;
    }

    function open(Game storage game, uint256 _gameId, bytes32 _secretHash, uint8 _v, bytes32 _r, bytes32 _s) internal {
        contributeSecret(game, _secretHash, _v, _r, _s);

        // create a new game
        game.uid = _gameId;
        // solium-disable-next-line security/no-block-members
        game.startTime = now;
    }

    function close(Game storage game, uint256 _secretKey, uint256 _revealPhaseDuration) internal
            validSecretKey(game, _secretKey) {
        game.revealPhaseDeadline = now + _revealPhaseDuration;
        game.secretKeys.push(_secretKey);
    }

    function revealSecretKey(Game storage game, uint256 _secretKey) internal
            inRevealPeriod(game)
            validSecretKey(game, _secretKey) {
        game.secretKeys.push(_secretKey);
    }

    function draw(Game storage game, uint256 _ballsCount, uint256 _ballsCountMax, uint256 _prizePool) internal {
        game.prizePool = _prizePool;

        bytes32 winningHash = keccak256(abi.encodePacked(game.secretKeys));
        bytes memory allNumbers = new bytes(_ballsCountMax);
        bytes memory winningNumbers = new bytes(_ballsCount);

        for (uint8 i = 0; i < _ballsCountMax; i++) {
            allNumbers[i] = byte(i + 1);
        }

        for (uint256 j = 0; j < _ballsCount; j++) {
            uint256 n = _ballsCountMax - j;
            uint256 r = (uint256(bytes32(winningHash[j * 4])) + (uint256(bytes32(winningHash[j * 4 + 1]) << 8)) + (uint256(bytes32(winningHash[j * 4 + 2]) << 16)) + (uint256(bytes32(winningHash[j * 4 + 3]) << 24))) % n;
            winningNumbers[j] = allNumbers[r];
            game.winningNumbersMap[winningNumbers[j]] = true;
            allNumbers[r] = allNumbers[n - 1];
        }
        game.winningNumbers = winningNumbers;
    }

    function buyTicket(Game storage game, bytes memory _ticket) internal
            noDuplicates(_ticket) {
        game.ticketSeq += 1;
        // solium-disable-next-line security/no-block-members
        game.tickets[game.ticketSeq] = Ticket(msg.sender, now, _ticket);
        emit TicketBought(game.uid, game.ticketSeq, msg.sender, _ticket);
    }

    function contributeSecret(Game storage game, bytes32 _secretHash, uint8 _v, bytes32 _r, bytes32 _s) internal
            validSignature(_secretHash, _v, _r, _s) {
        game.secretHashes[msg.sender] = _secretHash;
    }
}
