// Inject environemnt variable in this file
require("dotenv").config("./env");

// Import Web3
const Web3 = require("web3");

// Import abi
const abi = require("./abi.json");

const CONTRACT_ADDRESS="0x88F86Fee7bBf211d513FB657a3bcBc35b0a37160"

// create web3 instance
const web3 = new Web3(
  new Web3.providers.HttpProvider(process.env.URI)
);

// get the account object from private key
// const accountObj = web3.eth.accounts.privateKeyToAccount(
//   process.env.PRIVATE_KEY
// );

// add account to wallet
web3.eth.accounts.wallet.add("0x" + process.env.PRIVATE_KEY);

// get contract instance
const simplestorageContract = new web3.eth.Contract(
  abi,
  CONTRACT_ADDRESS
);

// read the value of number
simplestorageContract.methods
  .number()
  .call()
  .then((result) => {
    console.log("Initial value of number is ", result);
  });

// subscribe to contract event once
// simplestorageContract.once("Increment", (error, event) => {
//   console.log(event);
// });

// Use this code if you want to listen to events continuously.
// Refer https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html#events
// simplestorageContract.events
//   .Increment((error, event) => {
//     console.log(event);
//   })
//   .on("data", function (event) {
//     console.log(event); // same results as the optional callback above
//   })
//   .on("changed", function (event) {
//     // remove event from local database
//   })
//   .on("error", console.error);

// Use this code to increment the value
simplestorageContract.methods
  .increment()
  .estimateGas()
  .then((gas) => {
    simplestorageContract.methods
      .increment()
      .send({ from: web3.eth.accounts.wallet[0].address, gas });
  });

// deployed at 0xA78B7C039DfF2065e5F621e747D59798e16D65a0 on rinkeby
