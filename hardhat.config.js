require("@nomicfoundation/hardhat-toolbox");

require("solidity-coverage");
require("solidity-docgen");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false,
    token: 'ETH',
  },
  networks: {
    hardhat: {
      accounts: {
        count: 500
      }
    }
  },
  mocha: {
    slow: 0
  },
  docgen: {
    collapseNewlines: false,
    pages: "single"
  },
};
