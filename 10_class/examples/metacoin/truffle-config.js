module.exports = {
  // Uncommenting the defaults below 
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  //networks: {
  //  development: {
  //    host: "127.0.0.1",
  //    port: 7545,
  //    network_id: "*"
  //  },
  //  test: {
  //    host: "127.0.0.1",
  //    port: 7545,
  //    network_id: "*"
  //  }
  //}
  //
  compilers: {
    solc: {
      version: "0.7.1", // A version or constraint - Ex. "^0.5.0"
                         // Can also be set to "native" to use a native solc
      // { docker: <boolean>, // Use a version obtained through docker
      // parser: "solcjs",  // Leverages solc-js purely for speedy parsing
      // settings: {
        // optimizer: {
          // enabled: <boolean>,
          // runs: <number>   // Optimize for how many times you intend to run the code
        // },
        // evmVersion: <string> // Default: "istanbul"
      // }, }
      // { modelCheckerSettings: {
        // contains options for SMTChecker
      // } }
    }
  }
};
