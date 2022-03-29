const truffleAssert = require("truffle-assertions");
const BigNumber = require("bignumber.js");
const Faucet = artifacts.require("Faucet");

contract("Faucet", (accounts) => {
  const creator = accounts[0];
  const donor = accounts[1];
  const beneficiary = accounts[2];
  const withdrawalAmount = 200000000000000000;
  const refillAmount = 1000000000000000000;
  let facuetInstance;

  before(async () => {
    facuetInstance = await Faucet.deployed({ from: creator });
    await web3.eth.sendTransaction({
      from: donor,
      to: facuetInstance.address,
      value: refillAmount,
    });
    const balance = await web3.eth.getBalance(facuetInstance.address);
    assert.equal(
      refillAmount,
      balance,
      "The balance of contract should be as expected"
    );
  });

  it("should be able to withdraw using withdraw()", async () => {
    const beneficiaryBalance = await web3.eth.getBalance(beneficiary);
    const faucetBalance = await web3.eth.getBalance(facuetInstance.address);
    const tx = await facuetInstance.withdraw(
      web3.utils.toBN(withdrawalAmount),
      { from: beneficiary }
    );

    // Obtain the gasprice
    const trx = await web3.eth.getTransaction(tx.receipt.transactionHash);
    const transactionFee = web3.utils
      .toBN(trx.gasPrice)
      .mul(web3.utils.toBN(tx.receipt.gasUsed));
    const beneficiaryNewBalance = await web3.eth.getBalance(beneficiary);
    const faucetNewBalance = await web3.eth.getBalance(facuetInstance.address);
    const calculatedFaucetBalance = web3.utils.toBN(faucetBalance).sub(web3.utils.toBN(withdrawalAmount));
    const calculatedBeneficiaryBalance = web3.utils
      .toBN(beneficiaryBalance)
      .add(web3.utils.toBN(withdrawalAmount))
      .sub(transactionFee)
      .toString();

    assert.equal(
      beneficiaryNewBalance,
      calculatedBeneficiaryBalance,
      "the beneficiary balance is not as expected"
    );
    assert.equal(faucetNewBalance,calculatedFaucetBalance,"The contract balance is not as expected.")
    truffleAssert.eventEmitted(tx, "Withdrawal", (obj) => {
      return (
        obj.to === beneficiary &&
        new BigNumber(obj.amount).isEqualTo(new BigNumber(withdrawalAmount))
      );
    });
  });

  it("should revert on withdraw if amount exceed the contract balance", async () => {
    const withdrawalAmount = web3.utils.toBN(refillAmount).add(web3.utils.toBN(2000));
    await truffleAssert.reverts(
      facuetInstance.withdraw(withdrawalAmount, { from: beneficiary }),
      "Faucet: Insufficient balance for withdrawal request"
    );
  });
});
