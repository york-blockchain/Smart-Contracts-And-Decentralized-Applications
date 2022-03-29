## Demo : ERC20 York TokenSale

## Installation

1. Clone

   ```bash
    mkdir drizzle-tokensale && \
    cd ./drizzle-tokensale && \ 
    git init && \ 
    git remote add origin -f https://github.com/york-blockchain/Smart-Contracts-And-Decentralized-Applications.git && \
    git sparse-checkout init && \
    git sparse-checkout set class-10/examples/drizzle-tokensale && \
    git pull origin master && \ 
    mv class-10/examples/drizzle-tokensale/* . && \
    rm -rf ./.git ./notes
   ```

2. Dependencies
    ```bash
    npm install
    cd app && npm install
    cd ..
    ```

3. Run the development console.
    ```bash
    truffle develop
    ```

4. Compile and migrate the smart contracts. Note inside the development console we don't preface commands with `truffle`.
    ```javascript
    compile
    migrate
    ```

5. In the `app` directory, we run the React app. Smart contract changes must be manually recompiled and migrated.
    ```bash
    // in another terminal (i.e. not in the truffle develop prompt)
    cd app
    npm run start
    ```

6. Truffle can run tests written in Solidity or JavaScript against your smart contracts. Note the command varies slightly if you're in or outside of the development console.
    ```bash
    // inside the development console
    test

    // outside the development console
    truffle test
    ```

7. Jest is included for testing React components. Compile your contracts before running Jest, or you may receive some file not found errors.
    ```bash
    // ensure you are inside the app directory when running this
    npm run test
    ```

8. To build the application for production, use the build script. A production build will be in the `app/build` folder.
    ```bash
    // ensure you are inside the app directory when running this
    npm run build
    ```
