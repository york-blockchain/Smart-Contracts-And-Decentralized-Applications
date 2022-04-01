require("dotenv").config("./.env");
const { ethers } = require("ethers");
const axios = require("axios");

// Import abi
const abi = require("./abi.json");

// initialize with ganache
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");

// create a wallet instance i.e. signer
const wallet = new ethers.Wallet(`0x${process.env.PRIVATE_KEY}`, provider);

const ORACLE_ADDRESS = "0xF2A2FA1CB4493C5cDFd0f0631D9B627BA4B95E3d";

// oracle contract instance
const oracleInstance = new ethers.Contract(ORACLE_ADDRESS, abi, wallet);
oracleInstance.on("NewRequest", async (requestId) => {
  // console.log("Listened to event")
  console.log(requestId);
  const price = await getPrice();
  await oracleInstance.reply(
    requestId,
    ethers.utils.parseEther(price.toString())
  );
});

async function getPrice() {
  const response = await axios.get(
    `https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=MSFT&apikey=demo`
  );
  console.log(response.data["Global Quote"]["05. price"])
  return response.data["Global Quote"]["05. price"];
}
