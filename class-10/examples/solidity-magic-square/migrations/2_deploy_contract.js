const SquareLib = artifacts.require("SquareLib");
const MagicSquare = artifacts.require("MagicSquare");

module.exports = function(deployer) {
  deployer.deploy(SquareLib);
  deployer.link(SquareLib, MagicSquare);
  deployer.deploy(MagicSquare);
};
