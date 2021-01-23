# Coding Activity 
ERC20 : Any contract that follow the [ERC20 standard](https://eips.ethereum.org/EIPS/eip-20) is a ERC20 token.

ERC20 tokens provide functionalities to transfer tokens allow others to transfer tokens on behalf of the token holder

**ERC20 Interface.**

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
```

- Using Open Zeppelin it's really easy to create your own ERC20 token.

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, 100 * 10 ** uint(decimals()));
    }
}
```

Contract to swap tokens
Here is an example contract, TokenSwap, to trade one ERC20 token for another.

This contract will swap tokens by calling


transferFrom(address sender, address recipient, uint256 amount)
which will transfer amount of token from sender to recipient.

For transferFrom to succeed, sender must

have more than amount tokens in their balance
allowed TokenSwap to withdraw amount tokens by calling approve
prior to TokenSwap calling transferFrom

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol";

contract TokenSwap {
    IERC20 public token1;
    address public owner1;
    uint public amount1;
    IERC20 public token2;
    address public owner2;
    uint public amount2;

    constructor(
        address _token1,
        address _owner1,
        uint _amount1,
        address _token2,
        address _owner2,
        uint _amount2
    ) {
        token1 = IERC20(_token1);
        owner1 = _owner1;
        amount1 = _amount1;
        token2 = IERC20(_token2);
        owner2 = _owner2;
        amount2 = _amount2;
    }

    function swap() public {
        require(msg.sender == owner1 || msg.sender == owner2, "Not authorized");
        require(
            token1.allowance(owner1, address(this)) >= amount1,
            "Token 1 allowance too low"
        );
        require(
            token2.allowance(owner2, address(this)) >= amount2,
            "Token 2 allowance too low"
        );

        _safeTransferFrom(token1, owner1, owner2, amount1);
        _safeTransferFrom(token2, owner2, owner1, amount2);
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}
```

Test Contract on Remix IDE using following steps : 

1. Alice has 100 tokens from AliceCoin, which is a ERC20 token.
2. Bob has 100 tokens from BobCoin, which is also a ERC20 token.
3. Alice and Bob wants to trade 10 AliceCoin for 20 BobCoin.
4. Alice or Bob deploys TokenSwap
5. Alice appproves TokenSwap to withdraw 10 tokens from AliceCoin
6. Bob appproves TokenSwap to withdraw 20 tokens from BobCoin
7. Alice or Bob calls TokenSwap.swap()
8. Alice and Bob traded tokens successfully.
