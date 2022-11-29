const dotenv = require("dotenv");
dotenv.config(); // load env vars from .env
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

const { ARCHIVE_URL, MNEMONIC } = process.env;

if (!ARCHIVE_URL)
  throw new Error(
    `ARCHIVE_URL env var not set. Copy .env.template to .env and set the env var`
  );
if (!MNEMONIC)
  throw new Error(
    `MNEMONIC env var not set. Copy .env.template to .env and set the env var`
  );

const accounts = {
  // derive accounts from mnemonic, see tasks/create-key
  mnemonic: MNEMONIC,
};

// Go to https://hardhat.org/config/ to learn more
module.exports = {
  solidity: {
    solidity: "0.8.9",
    compilers: [
      // old ethernaut compilers
      { version: "0.5.0" },
      { version: "0.6.0" },
      { version: "0.6.12" },
      { version: "0.7.3" },
      {
        version: "0.8.4",
      },
      {
        version: "0.7.0",
      },
      {
        version: "0.6.6",
      },
      {
        version: "0.4.24",
      },
    ],
  },
  networks: {
    hardhat: {
      accounts,
      // forking: {
      //   url: "https://polygon-mumbai.g.alchemy.com/v2/TbuFA67XHLgTZvV3ZLM-xgf4WftoizvM",
      // },
    },
    rinkeby: {
      url: ARCHIVE_URL,
      accounts,
    },
    mumbai: {
      url: process.env.MUMBAI_RPC_URL,
      chainId: 80001,
      accounts: [process.env.METAMASK_MUMBAI_PRIVATE_KEY],
    },
    local_mumbai: {
      url: "http://127.0.0.1:7545",
      accounts: [process.env.METAMASK_MUMBAI_PRIVATE_KEY],
    },
    mumbai_fork: {
      url: "http://127.0.0.1:7545",
      chainId: 31337,
    },
  },
  mocha: {
    timeout: 300 * 1e3,
  },
};
