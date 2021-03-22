// Inject environemnt variable in this file
require("dotenv").config("./env");

// Import Web3
const Web3 = require("web3");

// Import BigNumber
const BigNumber = require("bignumber.js");

// Import ABI - use Remix
const abi = require("./abi.json");

// import compiled bytecode of contract - use Remix
const { bytecode } = require("./bytecode");

// create web3 instance
const web3 = new Web3(new Web3.providers.HttpProvider(process.env.URI));

// add account to wallet
web3.eth.accounts.wallet.add("0x" + process.env.PRIVATE_KEY);

const _number = new BigNumber(2);

// get contract instance
const simplestorageContract = new web3.eth.Contract(abi);

// estimateGas and deploy contract
simplestorageContract
  .deploy({
    data: `0x${bytecode}`,
    arguments: [_number],
  })
  .estimateGas()
  .then((gas) => {
    simplestorageContract
      .deploy({
        data: `0x${bytecode}`,
        arguments: [_number],
      })
      .send(
        {
          from: web3.eth.accounts.wallet[0].address,
          gas,
        },
        function (error, transactionHash) {}
      )
      .on("error", function (error) {
        console.log("error", error);
      })
      .on("transactionHash", function (transactionHash) {
        console.log("transactionHash", transactionHash);
      })
      .on("receipt", function (receipt) {
        console.log("receipt", receipt.contractAddress);
      })
      .on("confirmation", function (confirmationNumber, receipt) { // fired till 12th block is mined
        console.log("confirmation", confirmationNumber);
      })
      .on("error", console.error);
  })
  .catch((e) => {
    console.error(e);
  });

// deployed at 0xA78B7C039DfF2065e5F621e747D59798e16D65a0 on rinkeby
// deployed another at 0xa6F2d14748Ef0FF530f86E2b174f45503f2a520A on rinkeby 
// deployed another at 0x88F86Fee7bBf211d513FB657a3bcBc35b0a37160 on rinkeby 
