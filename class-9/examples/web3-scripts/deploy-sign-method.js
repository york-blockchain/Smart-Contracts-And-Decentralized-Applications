// Inject environemnt variable in this file
require("dotenv").config("./env");

// Import Web3
const Web3 = require("web3");

// Import BigNumber
const BigNumber = require("bignumber.js");

// Import abi
const abi = require("./abi.json");

const { bytecode } = require("./bytecode");

// create web3 instance
const web3 = new Web3(new Web3.providers.HttpProvider(process.env.URI));

// get the account object from private key
const accountObj = web3.eth.accounts.privateKeyToAccount(
  process.env.PRIVATE_KEY
);

const _number = new BigNumber(2);
const simplestorageContract = new web3.eth.Contract(abi);

const contractData = simplestorageContract
  .deploy({
    data: `0x${bytecode}`,
    arguments: [_number],
  })
  .encodeABI();
web3.eth
  .estimateGas({ from: accountObj.address, data: contractData })
  .then((gas) => {
    const rawTx = {
      from: accountObj.address,
      gas,
      data: contractData,
    };
    web3.eth.accounts
      .signTransaction(rawTx, accountObj.privateKey)
      .then(({ rawTransaction, transactionHash }) => {
        web3.eth
          .sendSignedTransaction(rawTransaction)
          .on("receipt", console.log);

        waitForReceipt(transactionHash, (result) => {
          console.log("The contract is deployed at ", result.contractAddress);
        });
      });
  });

// function to poll until transaction gets mined
function waitForReceipt(hash, cb) {
  web3.eth.getTransactionReceipt(hash, function (err, receipt) {
    if (err) {
      console.error(err);
    }
    if (receipt) {
      // Transaction went through
      if (cb) {
        cb(receipt);
      }
    } else {
      // Try again in 1 second
      console.log("Waiting to get mined...");
      setTimeout(function () {
        waitForReceipt(hash, cb);
      }, 1000);
    }
  });
}

// deployed at 0x8528204069eb6ef356a00e019329200c9fde4fd3 on rinkeby
// deployed another on 0x04994738ae2F099c02BB01Bd909f4be80c75F1a8 on rinkeby
// deployed another on 0x35D01bb5DF788259806a7B29C4f31Aa3B1Ab037d on rinkeby