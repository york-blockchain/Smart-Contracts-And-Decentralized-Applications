const YorkToken = artifacts.require("YorkToken");

module.exports = function (deployer) {
  deployer.deploy(YorkToken);
};
