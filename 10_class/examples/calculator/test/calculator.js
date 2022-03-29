// Using async-await

const Calculator = artifacts.require("Calculator");

contract("Calculator", (accounts) => {
  let contractInstance;

  before(async () => {
    contractInstance = await Calculator.new(10);
    console.log("Creating instances for all test cases!");
  });

  it("should return 10", async () => {
    const result = await contractInstance.getVal.call();
    assert.equal(await result.valueOf(), 10, "Test failed : should return 10");
  });

  it("should return 23", async () => {
    contractInstance.addNumber(10);
    contractInstance.subNumber(7);
    let result = await contractInstance.getVal.call();
    assert.equal(result.valueOf(), 13, "Test failed : should return 13");
    await contractInstance.addNumber(10);
    result = await contractInstance.getVal.call();
    assert.equal(result.valueOf(), 23, "Test failed : should return 23");
  });
});