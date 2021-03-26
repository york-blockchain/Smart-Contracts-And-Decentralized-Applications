import React from "react";
import { DrizzleContext } from "@drizzle/react-plugin";
import { Drizzle } from "@drizzle/store";
import { newContextComponents } from "@drizzle/react-components"
import drizzleOptions from "./drizzleOptions";
import './App.css';

const drizzle = new Drizzle(drizzleOptions);
const { ContractData, ContractForm } = newContextComponents;

const App = () => {
  return (
    <DrizzleContext.Provider drizzle={drizzle}>
      <DrizzleContext.Consumer>
        {
          (drizzleContext) => {
            const { drizzle, drizzleState, initialized } = drizzleContext;

            if (!initialized) {
              return "Loading..."
            }
            return (
              <div className="App">
                <header className="App-header">
                  <span>{drizzleState.accounts[0]}</span>
                  <ContractData
                    drizzle={drizzle}
                    drizzleState={drizzleState}
                    contract="YorkToken"
                    method="balanceOf"
                    methodArgs={[drizzleState.accounts[0]]}
                    render={((x) => {
                      return (
                        <span>{x/(10 ** 18)}</span>
                      )
                    })}
                  />{" "}
                  <ContractData
                    drizzle={drizzle}
                    drizzleState={drizzleState}
                    contract="YorkToken"
                    method="symbol"
                  />
                  <ContractForm
                  drizzle={drizzle}
                  drizzleState={drizzleState}
                  contract="YorkToken"
                  method="transfer"
                  />
                  {"Total Supply :"}
                  <ContractData
                    drizzle={drizzle}
                    drizzleState={drizzleState}
                    contract="YorkToken"
                    method="totalSupply"
                    render={((x) => {
                      return (
                        <span>{x/(10 ** 18)}</span>
                      )
                    })}
                  />
                </header>
              </div>
            )
          }
        }
      </DrizzleContext.Consumer>
    </DrizzleContext.Provider>
  );
}

export default App;
