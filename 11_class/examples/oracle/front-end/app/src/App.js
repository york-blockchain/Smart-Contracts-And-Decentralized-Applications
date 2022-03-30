import "./App.css";
import Web3 from "web3";
import React from "react";
import Stocks from "./contracts/Stocks.json";

const sleep = async (milliseconds) => {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
};

class App extends React.Component {
  stockQuote;
  web3 = new Web3(Web3.givenProvider || "http://localhost:7545");
  accounts;

  constructor(props) {
    super(props);
    this.state = { symbol: "", price: 0, volume: 0 };
  }

  componentDidMount = async () => {
    this.accounts = await this.web3.eth.getAccounts();
    let chainId = await this.web3.eth.net.getId();
    this.stockQuote = new this.web3.eth.Contract(
      Stocks["abi"],
      Stocks["networks"][chainId.toString()].address
    );
  };

  clickHandler = async (e) => {
    e.preventDefault();
    let result = await fetch(`http://localhost:8000/${this.state.symbol}`);
    let json = await result.json();
    this.stockQuote.methods
      .setStock(
        this.web3.utils.fromAscii(this.state.symbol),
        parseInt(json.price),
        json.volume
      )
      .send({ from: this.accounts[0] })
      .on("receipt", async () => {
        sleep(1000).then(async () => {
          let price = await this.stockQuote.methods
            .getStockPrice(this.web3.utils.fromAscii(this.state.symbol))
            .call();
          let volume = await this.stockQuote.methods
            .getStockVolume(this.web3.utils.fromAscii(this.state.symbol))
            .call();
          this.setState({ price, volume });
        });
        console.log(this.state.price, this.state.volume);
      });
  };

  handleSymbolChange = (e) => {
    this.setState({ symbol: e.target.value });
  };

  render() {
    return (
      <div className="setStock">
        <form>
          <div>
            <label htmlFor="symbol">Symbol:</label>
            <input
              type="text"
              name="symbol"
              onChange={this.handleSymbolChange}
            />
          </div>
          <div>
            <label>Price: {this.state.price}</label>
          </div>
          <div>
            <label>Volume: {this.state.volume}</label>
          </div>
          <div>
            <input type="submit" onClick={this.clickHandler} value="setStock" />
          </div>
        </form>
      </div>
    );
  }
}

export default App;
