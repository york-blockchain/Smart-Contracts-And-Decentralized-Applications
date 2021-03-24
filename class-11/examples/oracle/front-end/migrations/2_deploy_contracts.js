const Stocks = artifacts.require("Stocks");

module.exports = function (deployer) {
  return deployer.deploy(Stocks);
};
