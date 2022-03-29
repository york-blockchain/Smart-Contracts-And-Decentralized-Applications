import React, { useState, useEffect } from "react";
import { newContextComponents } from "@drizzle/react-components";
import ProgressBar from "./progress-bar.component";
import "./tachyons.min.css";

const { ContractData, ContractForm } = newContextComponents;

export default ({ drizzle, drizzleState }) => {
  const [numberOfTokens, setTokens] = useState(1);
  const [decimals, setDecimals] = useState(0);
  const [tokensSold, setTokensSold] = useState(0);
  const [completed, setCompleted] = useState(0);
  const [remainingTokens, setRemainingTokens] = useState(0);

  useEffect(() => {
    const init = async () => {
      const decimalData = await drizzle.contracts.GBCToken.methods
        .decimals()
        .call();
      setDecimals(decimalData);
      const tokensSoldData = await drizzle.contracts.TokenSale.methods
        .tokensSold()
        .call();
      setTokensSold(tokensSoldData);
      const remainingTokensData = await drizzle.contracts.GBCToken.methods
      .balanceOf(drizzle.contracts.TokenSale.address)
      .call();
      setRemainingTokens(remainingTokensData);
      setCompleted((tokensSoldData*100)/(parseInt(tokensSoldData)+parseInt(remainingTokensData/10 ** decimalData)))
    };
    init();
  }, []);

  // destructure drizzle and drizzleState from props
  return (
    <div className="App">
      <div className="section">
        <main className="mw7 center" role="main">
          <div className="flex-l mt2 w8 center article-container">
            <article className="cf pv3 ph3 ph4-ns w-100">
              <header>
                <h1 className="f1 mb1">GBC Token Sale</h1>
              </header>
              <div id="ui">
                <p className="mt4">
                  Your current balance:{" "}
                  <ContractData
                    drizzle={drizzle}
                    drizzleState={drizzleState}
                    contract="GBCToken"
                    method="balanceOf"
                    methodArgs={[drizzleState.accounts[0]]}
                    render={(x) => {
                      return <span>{x / 10 ** decimals}</span>;
                    }}
                  />{" "}
                  <ContractData
                    drizzle={drizzle}
                    drizzleState={drizzleState}
                    contract="GBCToken"
                    method="symbol"
                  />
                  . Buy more! Each token costs 0.00001 ether.
                </p>
                <ContractForm
                  drizzle={drizzle}
                  contract="TokenSale"
                  method="buyTokens"
                  sendArgs={{ value: 10000000000000 * numberOfTokens }}
                  render={({ handleInputChange, handleSubmit }) => {
                    return (
                      <form
                        id="setForm"
                        className="br2-ns"
                        onSubmit={(e) => {
                          handleSubmit(e);
                        }}
                      >
                        <fieldset className="cf bn ma0 pa0">
                          <div className="cf">
                            <label className="clip" htmlFor="number">
                              Number of tokens to buy
                            </label>
                            <input
                              className="f6 f5-l input-reset bn bg-near-white fl black-80 pa3 lh-solid w-100 w-75-m w-80-l br2-ns br--left-ns"
                              placeholder="Number of tokens to buy"
                              type="number"
                              name="numberOfTokens"
                              value={numberOfTokens}
                              min="1"
                              id="setNumber"
                              onChange={(e) => {
                                setTokens(e.target.value);
                                handleInputChange(e);
                              }}
                            />
                            <input
                              className="f6 f5-l button-reset fl pv3 tc bn bg-animate bg-blue hover-bg-dark-red white pointer w-100 w-25-m w-20-l br2-ns br--right-ns"
                              type="submit"
                              value="Buy Tokens"
                            />
                          </div>
                        </fieldset>
                      </form>
                    );
                  }}
                />
                <ProgressBar bgcolor={"#6a1b9a"} completed={completed} />
                <small className="f6 black-60 db mb2 tr mt2">
                  <span id="sold">
                    <ContractData
                      drizzle={drizzle}
                      drizzleState={drizzleState}
                      contract="TokenSale"
                      method="tokensSold"
                      render = {
                        (x) => {
                          setTokensSold(x);
                          return <span>{x}</span>
                        }
                      }
                    />
                  </span>{" "}
                  /{" "}
                  <span id="total">
                    <ContractData
                      drizzle={drizzle}
                      drizzleState={drizzleState}
                      contract="GBCToken"
                      method="balanceOf"
                      methodArgs={[drizzle.contracts.TokenSale.address]}
                      render={(x) => {
                        setRemainingTokens(x);
                        setCompleted((tokensSold*100)/(parseInt(tokensSold)+parseInt(x/10 ** decimals)))
                        return (
                          <span>
                            {parseInt(x) / 10 ** decimals +
                              parseInt(tokensSold)}
                          </span>
                        );
                      }}
                    />
                  </span>{" "}
                  tokens sold so far
                </small>
              </div>
            </article>
          </div>
        </main>
      </div>
    </div>
  );
};
