const ERC20 = artifacts.require("StandardERC20");

module.exports = function(deployer) {
  deployer.deploy(ERC20,"GBC Token", "GBC",6,web3.utils.toBN(100000000));
};
