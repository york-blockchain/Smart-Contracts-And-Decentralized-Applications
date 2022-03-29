const StandardERC20 = artifacts.require("StandardERC20");
const BigNumber = require("bignumber.js");
const truffleAssert = require("truffle-assertions");

contract("StandardERC20", (accounts) => {
  const tokenNameExpected = "GBC Token";
  const tokenSymbolExpected = "GBC";
  const tokenDecimalsExpected = web3.utils.toBN(6);
  const tokenSupplyExpected = web3.utils.toBN(100000000);
  const creator = accounts[0];
  const recipient1 = accounts[1];
  const recipient1Amount = web3.utils.toBN(10000000);
  const spender = accounts[2];
  const spenderAmount = web3.utils.toBN(5000000);
  const recipient2 = accounts[3];
  const recipient2Amount = web3.utils.toBN(3000000);
  let standardERC20Instance;
  before(async () => {
    standardERC20Instance = await StandardERC20.deployed();
    const name = await standardERC20Instance.name();
    const symbol = await standardERC20Instance.symbol();
    const decimals = await standardERC20Instance.decimals();
    const totalSupply = await standardERC20Instance.totalSupply();
    assert.equal(name, tokenNameExpected, "Token name is not as expected");
    assert.equal(
      symbol,
      tokenSymbolExpected,
      "Token symbol is not as expected"
    );
    assert(
      new BigNumber(decimals).isEqualTo(new BigNumber(tokenDecimalsExpected)),
      "Token decimals is not as expected"
    );
    assert(
      new BigNumber(totalSupply).isEqualTo(new BigNumber(tokenSupplyExpected)),
      "Token supply is not as expected"
    );
  });

  it("test balanceOf()", async () => {
    const tokenBalanceInCreator = await standardERC20Instance.balanceOf.call(
      creator
    );

    assert(
      new BigNumber(tokenBalanceInCreator).isEqualTo(
        new BigNumber(tokenSupplyExpected)
      ),
      "Token balance in creator is not as expected"
    );
  });

  it("test transfer()", async () => {
    const creatorOldBalanceFromContract = await standardERC20Instance.balanceOf.call(
      creator
    );

    const tx = await standardERC20Instance.transfer(
      recipient1,
      recipient1Amount,
      { from: creator }
    );

    const recipient1Balance = recipient1Amount;

    const recipient1BalanceFromContract = await standardERC20Instance.balanceOf.call(
      recipient1
    );

    const creatorBalanceFromContract = await standardERC20Instance.balanceOf.call(
      creator
    );

    const creatorExpectedBalance = web3.utils
      .toBN(creatorOldBalanceFromContract)
      .sub(web3.utils.toBN(recipient1Amount));

    assert(
      new BigNumber(creatorExpectedBalance).isEqualTo(
        new BigNumber(creatorBalanceFromContract)
      ),
      "creator's new token balance is not as expected"
    );

    truffleAssert.eventEmitted(tx, "Transfer", (obj) => {
      return (
        obj.from === creator &&
        obj.to === recipient1 &&
        new BigNumber(recipient1Amount).isEqualTo(new BigNumber(obj.value))
      );
    });

    assert(
      new BigNumber(recipient1Balance).isEqualTo(
        new BigNumber(recipient1BalanceFromContract)
      ),
      "recipient1's token balance is not as expected"
    );
  });

  it("test transferFrom()", async () => {
    // approve
    const oldRecipient1Balance = await standardERC20Instance.balanceOf.call(
      recipient1
    );

    const approveTx = await standardERC20Instance.approve(
      spender,
      spenderAmount,
      { from: recipient1 }
    );

    truffleAssert.eventEmitted(approveTx, "Approval", (obj) => {
      return (
        obj.owner === recipient1 &&
        obj.spender === spender &&
        new BigNumber(spenderAmount).isEqualTo(new BigNumber(obj.value))
      );
    });

    const allowanceFromContract = await standardERC20Instance.allowance.call(
      recipient1,
      spender
    );

    assert(
      new BigNumber(allowanceFromContract).isEqualTo(
        new BigNumber(spenderAmount)
      ),
      "spender's allowance is not as expected"
    );

    // transfer

    const transferFromTx = await standardERC20Instance.transferFrom(
      recipient1,
      recipient2,
      recipient2Amount,
      { from: spender }
    );

    truffleAssert.eventEmitted(transferFromTx, "Transfer", (obj) => {
      return (
        obj.from === recipient1 &&
        obj.to === recipient2 &&
        new BigNumber(recipient2Amount).isEqualTo(new BigNumber(obj.value))
      );
    });

    const recipient2Balance = await standardERC20Instance.balanceOf(recipient2);

    assert(
      new BigNumber(recipient2Balance).isEqualTo(
        new BigNumber(recipient2Amount)
      ),
      "recipient2's balance is not as expected"
    );

    const expectedRecipient1Balance = web3.utils
      .toBN(oldRecipient1Balance)
      .sub(recipient2Amount);

    const recipient1BalanceFromContract = await standardERC20Instance.balanceOf(
      recipient1
    );

    assert(
      new BigNumber(recipient1BalanceFromContract).isEqualTo(
        new BigNumber(expectedRecipient1Balance)
      ),
      "recipient1's balance is not as expected"
    );
  });
  it("test revert transfer()", async () => {
    const transferAmount = web3.utils.toBN(105000000);

    await truffleAssert.reverts(
      standardERC20Instance.transfer(recipient1, transferAmount, {
        from: creator,
      }),
      "ERC20: sender does not have enough amount"
    );
  });

  it("test revert approve()", async () => {
    const approveAmount = web3.utils.toBN(11000000);

    await truffleAssert.reverts(
      standardERC20Instance.approve(spender, approveAmount, {
        from: recipient1,
      }),
      "ERC20: owner does not have enough amount"
    );
  });

  it("test address(0) recipient transfer()", async () => {
      const recipient = "0x0000000000000000000000000000000000000000";

      await truffleAssert.reverts(
        standardERC20Instance.transfer(
            recipient,
            recipient1Amount,
            { from: creator }
          ), "ERC20: transfer from zero transfer"
      )
  });

  it("test address(0) sender transferFrom()", async () => {
    const sender = "0x0000000000000000000000000000000000000000";

    await truffleAssert.reverts(
      standardERC20Instance.transferFrom(
          sender,
          recipient1,
          recipient1Amount,
          { from: creator }
        ), "ERC20: transfer from zero transfer"
    )
});

  it("test address(0) spender approve()", async () => {
    const spenderAddr = "0x0000000000000000000000000000000000000000";

    truffleAssert.reverts(
        standardERC20Instance.approve(
            spenderAddr,
            spenderAmount,
            { from: recipient1 }
          ),
          "ERC20: transfer from zero transfer"
    )
  });
});
