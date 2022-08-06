const dotenv = require("dotenv");
dotenv.config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
const { PRIVATE_KEY } = process.env;
/** @type import('hardhat/config').HardhatUserConfig */
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: "4ICRRP7HA8RA1IZ4FCIJ1ZK89WARFQFRN5",
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {},
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      gas: 2100000,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      gas: 2100000,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    rinkeby: {
      url: "https://speedy-nodes-nyc.moralis.io/3ff17d7d4b11fbfa8d5cb8fc/eth/rinkeby",
      accounts: [`0x${PRIVATE_KEY}`],
      gas: 210000000,
      gasPrice: 8000000000000,
    },
    matic: {
      url: "https://matic-mumbai.chainstacklabs.com/",
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  mocha: {
    timeout: 20000,
  },
};
