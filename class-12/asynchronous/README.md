# Coding Activity
Develop Simple Payment Channel

- [Explanation Video](https://youtu.be/d1oL_S1MNCI)

- In this activity, we’ll build a simple, but complete, implementation of a payment channel. - Payment channels use cryptographic signatures to make repeated transfers of ether securely, instantaneously, and without transaction fees.
- It assumed you have knowledge of signing and verifying messages in Ethereum.

## Payment Channel
- Ethereum transactions provide a secure way to transfer funds, but each transaction needs to be included in a block and mined. 
- This means transactions take some time and require payment to compensate the miners for their work. 
- In particular, transaction fees make micropayments a difficult use case for Ethereum and other blockchains like it.

- Payment channels allow participants to make repeated transfers of ether without using transactions. 
- Delays and fees associated with transactions can be avoided. 
- We'll develop a simple unidirectional payment channel between two parties. 

**Using it involves three steps:**

1. The sender funds a smart contract with ether. This “opens” the payment channel.
2. The sender signs messages that specify how much of that ether is owed to the recipient. This step is repeated for each payment.
3. The recipient “closes” the payment channel, withdrawing their portion of the ether and sending the remainder back to the sender.

![payment channel](./assets/payment-channel.png)

- Importantly, only steps 1 and 3 require Ethereum transactions. 
- Step 2 is accomplished off-chain through cryptographic signatures and some sort of communication between the two parties, such as email. 
- Only two transactions are required to support any number of transfers.

- The recipient is guaranteed to receive their funds because the smart contract escrows the ether and honors a valid signed message. 
- The smart contract also enforces a timeout, so the sender is guaranteed to eventually recover their funds even if the recipient refuses to close the channel.


## Opening the Payment Channel

- To open the payment channel, the sender deploys the smart contract, attaching the ether to be escrowed and specifying the intended recipient and a maximum duration for the channel to exist.

```js
contract SimplePaymentChannel {
    address public sender;     // The account sending payments.
    address public recipient;  // The account receiving the payments.
    uint256 public expiration; // Timeout in case the recipient never closes.

    constructor(address _recipient, uint256 duration)
        public
        payable
    {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }
```

## Making Payments
- The sender makes payments by sending messages to the recipient. This step is performed entirely outside of the Ethereum network. 
- Messages are cryptographically signed by the sender and then transmitted directly to the recipient.

**Each message includes the following information:**

- The smart contract’s address, used to prevent cross-contract replay attacks.
- The total amount of ether that is owed the recipient so far.
- A payment channel is closed just once, at the end of a series of transfers. 
- Because of this, only one of the messages sent will be redeemed. 
- This is why each message specifies a cumulative total amount of ether owed, rather than the amount of the individual micropayment. 
- The recipient will naturally choose to redeem the most recent message because that’s the one with the highest total.

- Note that because the smart contract will only honor a single message, no per-message nonce is required. 
- The address of the smart contract is still used to prevent a message intended for one payment channel from being used for a different channel.

- Payment messages can be constructed and signed in any language that supports cryptographic hashing and signing operations. The following code is written in JavaScript and uses ethereumjs-abi:

```js
function constructPaymentMessage(contractAddress, amount) {
  return ethereumjs.ABI.soliditySHA3(
    ["address", "uint256"],
    [contractAddress, amount],
  );
}

function signMessage(message, callback) {
  web3.personal.sign("0x" + message.toString("hex"), web3.eth.defaultAccount,
    callback);
}

// contractAddress is used to prevent cross-contract replay attacks.
// amount, in wei, specifies how much ether should be sent.
function signPayment(contractAddress, amount, callback) {
    var message = constructPaymentMessage(contractAddress, amount);
    signMessage(message, callback);
}
```

## Verifying Payments
- The recipient keeps track of the latest message and redeems it when it’s time to close the payment channel. 
- This means it’s critical that the recipient perform their own verification of each message. Otherwise there is no guarantee that the recipient will be able to get paid in the end.

- The recipient should verify each message using the following process:

  1. Verify that the contract address in the message matches the payment channel.
  2. Verify that the new total is the expected amount.
  3. Verify that the new total does not exceed the amount of ether escrowed.
  4. Verify that the signature is valid and comes from the payment channel sender.

The first three steps are straightforward. The final step can be performed a number of ways, but if it’s being done in JavaScript. The following code borrows the `constructMessage` function from the signing code above:

```js
// This mimics the prefixing behavior of the eth_sign JSON-RPC method.
// Builds a prefixed hash to mimic the behavior of eth_sign.
    function _prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

function _recoverSigner(bytes32 _message, bytes memory _sig) internal pure returns (address)
{
    uint8 _v;
    bytes32 _r;
    bytes32 _s;

    (_v, _r, _s) = _splitSignature(_sig);

    return ecrecover(_message, _v, _r, _s);
}

// Builds a prefixed hash to mimic the behavior of eth_sign.
function _prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
}
```

## Closing the Payment Channel

- When the recipient is ready to receive their funds, it’s time to close the payment channel by calling a close function on the smart contract. 
- Closing the channel pays the recipient the ether they’re owed and destroys the contract, sending any remaining ether back to the sender. 
- To close the channel, the recipient needs to share a message signed by the sender.

- The smart contract must verify that the message contains a valid signature from the sender. 
- The process for doing this verification is the same as the process the recipient uses. 
- The Solidity functions `_isValidSignature` and ``_`recoverSigner` work just like their JavaScript counterparts in the previous section. The latter is borrowed from the `ReceiverPays` contract in “Signing and Verifying Messages in Ethereum”.

```js
 function _isValidSignature(uint256 _amount, bytes memory _signature)internal view returns (bool)
    {
        bytes32 message = _prefixed(keccak256(abi.encodePacked(address(this), _amount)));

        // Check that the signature is from the payment sender.
        return _recoverSigner(message, _signature) == sender;
    }

// The recipient can close the channel at any time by presenting a signed
// amount from the sender. The recipient will be sent that amount, and the
// remainder will go back to the sender.
function close(uint256 _amount, bytes memory _signature) public {
    require(msg.sender == recipient);
    require(_isValidSignature(_amount, _signature));

    payable(recipient).transfer(_amount);
    selfdestruct(payable(sender));
}
```

- The close function can only be called by the payment channel recipient, who will naturally pass the most recent payment message because that message carries the highest total owed. 
- If the sender were allowed to call this function, they could provide a message with a lower amount and cheat the recipient out of what they’re owed.

- The function verifies the signed message matches the given parameters. - If everything checks out, the recipient is sent their portion of the ether, and the sender is sent the rest via a `selfdestruct`.

## Channel Expiration
- The recipient can close the payment channel at any time, but if they fail to do so, the sender needs a way to recover their escrowed funds. 
- An expiration time was set at the time of contract deployment. Once that time is reached, the sender can call claimTimeout to recover their funds.

```js
// If the timeout is reached without the recipient closing the channel, then
// the ether is released back to the sender.
function claimTimeout() public {
        require(now >= expiration);
        selfdestruct(payable(sender));
    }
```

- There’s no reason not to allow the sender to extend expiration. I’ve included a function in the full source code that does this.
- After this function is called, the recipient can no longer receive any ether, so it’s important that the recipient close the channel before the expiration is reached.

## Key TakeAways
- Payment channels support safe, off-chain fund transfers while avoiding per-transfer Ethereum transaction fees.
- Payments are cumulative, and only one is redeemed when closing the channel.
- Transfers are guaranteed via escrowed funds and cryptographic signatures.
- A timeout protects the sender’s funds from an uncooperative recipient.

`simplePaymentChannel.sol`

```js
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

contract SimplePaymentChannel {
    address public sender;     // The account sending payments.
    address public recipient;  // The account receiving the payments.
    uint256 public expiration; // Timeout in case the recipient never closes.

    constructor(address _recipient, uint256 duration)
        public
        payable
    {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }

    function _isValidSignature(uint256 _amount, bytes memory _signature)
        internal
        view
        returns (bool)
    {
        bytes32 message = _prefixed(keccak256(abi.encodePacked(address(this), _amount)));

        // Check that the signature is from the payment sender.
        return _recoverSigner(message, _signature) == sender;
    }

    // The recipient can close the channel at any time by presenting a signed
    // amount from the sender. The recipient will be sent that amount, and the
    // remainder will go back to the sender.
    function close(uint256 _amount, bytes memory _signature) public {
        require(msg.sender == recipient);
        require(_isValidSignature(_amount, _signature));

        payable(recipient).transfer(_amount);
        selfdestruct(payable(sender));
    }

    // The sender can extend the expiration at any time.
    function extend(uint256 newExpiration) public {
        require(msg.sender == sender);
        require(newExpiration > expiration);

        expiration = newExpiration;
    }

    // If the timeout is reached without the recipient closing the channel, then
    // the ether is released back to the sender.
    function claimTimeout() public {
        require(now >= expiration);
        selfdestruct(payable(sender));
    }

    function _splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function _recoverSigner(bytes32 _message, bytes memory _sig)
        internal
        pure
        returns (address)
    {
        uint8 _v;
        bytes32 _r;
        bytes32 _s;

        (_v, _r, _s) = _splitSignature(_sig);

        return ecrecover(_message, _v, _r, _s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function _prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
```