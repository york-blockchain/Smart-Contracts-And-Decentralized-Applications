# Coding Activity
Continuous integration (CI) with Truffle 

- Continuous integration is great for developing once you have a basic set of tests implemented. 
- It allows you to run very long tests, ensure all tests pass before merging a [pull request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) and to keep track of various statistics using additional tools.

- We will use the [Truffle Metacoin Box](https://github.com/truffle-box/metacoin-box) to setup our continuous integration. You can either choose Travis CI or Circle CI.

## SETTING UP TRAVIS CI

- Adding [Travis CI](https://travis-ci.org/) is straight-forward. You will only need to add a `.travis.yml` config file to the root folder of the project:

```
language: node_js
node_js:
  - 10
cache: npm
before_script:
  - echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
script:
  - npm test
```

- We are only running the test script which executes the Truffle unit tests. 
- There won't be a blockchain available on the Travis CI machine so we will install `ganache-cli` by running `npm install ganache-cli` and simply run it before the test. 
- You can do this by adding a bash script with the line `npx ganache-cli > /dev/null` and before the `npx truffle test` call. Here is the full example bash script.

```bash
#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
  # Kill the ganache instance that we started (if we started one and if it's still running).
  if [ -n "$ganache_pid" ] && ps -p $ganache_pid > /dev/null; then
    kill -9 $ganache_pid
  fi
}

ganache_port=8545

ganache_running() {
  nc -z localhost "$ganache_port"
}

start_ganache() {
  npx ganache-cli --gasLimit 0x1fffffffffffff --gasPrice 0x1 --port "$ganache_port" --accounts 70 > /dev/null &
  ganache_pid=$!

  echo "Waiting for ganache to launch on port "$ganache_port"..."

  while ! ganache_running; do
    sleep 0.1 # wait for 1/10 of the second before check again
  done

  echo "Ganache launched!"
}

if ganache_running; then
  echo "Using existing ganache instance"
else
  echo "Starting our own ganache instance"
  start_ganache
fi

npx truffle version
npx truffle test "$@"
```

## SETTING UP CIRCLE CI

- [CircleCi](https://circleci.com/) requires a longer config file. 
- The additional [`npm ci`](https://docs.npmjs.com/cli/v6/commands/npm-cicommand) is automatically done in Travis. It installs dependencies faster and more securely than `npm install` does. - We again use the same script from the Travis version to run ganache-cli before the tests.

```
version: 2
aliases:
  - &defaults
    docker:
      - image: circleci/node:10
  - &cache_key_node_modules
    key: v1-node_modules-{{ checksum "package-lock.json" }}
jobs:
  dependencies:
    <<: *defaults
    steps:
      - checkout
      - restore_cache:
          <<: *cache_key_node_modules
      - run:
          name: Install npm dependencies
          command: |
            if [ ! -d node_modules ]; then
              npm ci
            fi
      - persist_to_workspace:
          root: .
          paths:
            - node_modules
            - build
      - save_cache:
          paths:
            - node_modules
          <<: *cache_key_node_modules
  test:
    <<: *defaults
    steps:
      - checkout
      - attach_workspace:
          at: .
      - run:
          name: Unit tests
          command: npm test
workflows:
  version: 2
  everything:
    jobs:
      - dependencies
      - test:
          requires:
            - dependencies
```

## ADDING THE ETH-GAS-REPORTER PLUGIN

- The eth-gas-reporter plugin is quite useful for keeping track of the gas costs of your smart contract functions. Having it in your CI will further be useful for showing diffs when adding pull requests.

### Step 1: Install the eth-gas-reporter plugin and codechecks

```bash
$ npm install --save-dev eth-gas-reporter
$ npm install --save-dev @codechecks/client
```

### Step 2: Add the plugin to the mocha settings inside your truffle-config.js

```js
module.exports = {
  networks: { ... },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      excludeContracts: ['Migrations']
    }
  }
};
```

### Step 3: Add a codechecks.yml to your project's root directory

```
checks:
  - name: eth-gas-reporter/codechecks
```

### Step 4: Run codechecks after the test command

```bash
- npm test
- npx codechecks
```

### Step 5: Create a Codechecks account

- Create an account with [Codechecks](https://www.codechecks.io/).
- Add the Github repo to it.
- Copy the secret and add the `CC_SECRET=COPIED SECRET` to your CI (see here for [Travis](https://docs.travis-ci.com/user/environment-variables/), here for [CircleCi](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project)).
- Now go ahead and create a pull request.
- You will now find a nice report about changes in gas costs of your pull request.

![gas reports](./assets/gas-reports.png)

## ADDING THE SOLIDITY-COVERAGE PLUGIN

- With the solidity-coverage plugin you can check how much of your code paths are covered by your tests. Adding this to your CI makes is very convenient to use once it is set up.

### Step 1: Create a metacoin project and install coverage tools

```bash
$ npm install --save-dev truffle
$ npm install --save-dev coveralls
$ npm install --save-dev solidity-coverage
```

### Step 2: Add solidity-coverage to the plugins array in truffle-config.js

```js
module.exports = {
  networks: {...},
  plugins: ["solidity-coverage"]
}
```

### Step 3: Add the coverage commands to the .travis.yml or Circle CI config.yml

```js
- npx truffle run coverage
- cat coverage/lcov.info | npx coveralls
```

- Solidity coverage starts its own `ganache-cli`, so we don't have to worry about this. Do not replace the regular test command though, coverage's ganache-cli works differently and is therefore no replacement for running regular unit tests.

### Step 4: Add repository to coveralls
- Create an account with Coveralls.
- Add the Github repo to it.
- Now go ahead and create a pull request.

![coverall](./assets/coverall.png)