require("dotenv").config("./.env");
const { ethers } = require("ethers");

// Import abi
const abi = require("./abi.json");

// import bytecode
const { bytecode } = require("./bytecode");

// initialise with infura provider i.e. rinkeby network
const provider = new ethers.providers.InfuraProvider(
  "rinkeby",
  process.env.INFURA_KEY
);

// create a wallet instance i.e. signer
const wallet = new ethers.Wallet(`0x${process.env.PRIVATE_KEY}`, provider);

// contract factory instance
const factory = new ethers.ContractFactory(abi, bytecode, wallet);

// deploy the contract
factory.deploy(2).then(async (contract) => {
  // contract deployment
  await contract.deployed();
  console.log("Deployed at ", contract.address);

  // get the instance after contract is deployed
  const contractInstance = new ethers.Contract(contract.address, abi, provider);

  // get the signer from deployed contract and wallet
  const contractSigner = contractInstance.connect(wallet);
  contractSigner.number().then((_num) => {
    console.log("The queried number is ", _num);
    contractSigner.increment().then(async (tx) => {
      await tx.wait();
      console.log("Increment function is called");

      contractSigner.number().then((_num) => {
        console.log("The queried number is ", _num);
      });
    });
  });
});

// contract is deployed at 0x5F7C2f13E6eabfac0E4E2C74Cd69056647DcE0b4 on rinkeby
// contract is deployed at 0xaD7DDecb646ab6849E13ABdfb1C5b1F2A377Bd32 ono rinkeby
