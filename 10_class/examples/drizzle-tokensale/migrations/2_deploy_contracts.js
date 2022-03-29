const YorkToken = artifacts.require("GBCToken");
const TokenSale = artifacts.require("TokenSale");

module.exports = function (deployer) {
  deployer.deploy(YorkToken).then((yorkTokenInstance) => {
    return deployer
      .deploy(TokenSale, yorkTokenInstance.address, "10000000000000")
      .then((tokenSaleInstance) => {
        return yorkTokenInstance.transfer(
          tokenSaleInstance.address,
          "100000000000000000000"
        );
      });
  });
};
