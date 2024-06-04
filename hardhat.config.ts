const { task, HardhatUserConfig } = require("hardhat/config");
const { config: dotenvConfig } = require("dotenv");
const { resolve } = require("path");
require("hardhat-preprocessor");
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-contract-sizer");
require("hardhat-tracer");
require("hardhat-gas-reporter");
require("hardhat-abi-exporter");
require("hardhat-diamond-abi");
require("hardhat-storage-layout");
require("@nomiclabs/hardhat-web3");
require("@tenderly/hardhat-tenderly");

const dotenvConfigPath = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

const mnemonic = process.env.MNEMONIC || "";
const privateKeys = process.env.PRIVATE_KEYS ? process.env.PRIVATE_KEYS.split(',') : []
if (!mnemonic && !privateKeys.length) {
  throw new Error("Please set your MNEMONIC or PRIVATE_KEYS in a .env file");
}
if (!process.env.TENDERLY_USERNAME || !process.env.TENDERLY_PROJECT) {
  throw new Error("Please set your TENDERLY_USERNAME and TENDERLY_PROJECT in a .env file");
}

module.exports = {
  gasReporter: {
    enabled: true
  },
  etherscan: {
    apiKey: {
      polygonMumbai: "PPRGSSD8PYNSY1GTXWKFFAS86UABMDZA5H"
    }
  },
  networks: {
    localhost: {
      accounts: privateKeys,
      timeout: 16000000,
    },
    local: {
      accounts: {
        count: 10,
        mnemonic: "fan heavy genius assume deny caught carry trophy stem throw edge trade",
        path: "m/44'/60'/0'/0",
      },
      chainId: 31337,
      url: "http://127.0.0.1:8545",
    },
    redstone: {
      accounts: {
        count: 6,
        mnemonic,
        path: "m/44'/60'/0'/0",
      },
      chainId: 17069,
      timeout: 200016000000,
      gasPrice: 1000000,
      url: "https://rpc.garnetchain.com",
    }
  },
  diamondAbi: [
    {
      name: "TxFarmDiamond",
      include: [
        'AccessControlFacet',
        'BlueprintFacet',
        'LandFacet',
        'ItemFacet',
        'StoreFacet',
        'InventoryFacet',
        'CurrencyFacet',
        // 'BreedingFacet',
        'OrderFacet',
        'UtilitiesFacet',
        'EIP2771Facet',
        'PausableFacet',
        'RegistryFacet',
        'UserProfileFacet',
        // 'CraftingFacet'
      ],
      strict: false
    }
  ],
  contractSizer: {
    alphaSort: false,
    runOnCompile: false,
    disambiguatePaths: true,
  },
  mocha: {
    timeout: 20000000,
  },
  solidity: {
    version: "0.8.20",
    settings: {
      metadata: {
        // Not including the metadata hash
        // https://github.com/paulrberg/hardhat-template/issues/31
        bytecodeHash: "none",
      },
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  tenderly: {
    username: process.env.TENDERLY_USERNAME,
    project: process.env.TENDERLY_PROJECT,
    privateVerification: false
  }
};
