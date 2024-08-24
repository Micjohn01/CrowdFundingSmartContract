const { vars } = require("hardhat/config");

require("@nomicfoundation/hardhat-toolbox");

const SECRET_KEY = vars.get("PRIVATE_KEY");
const ALCHEMY = vars.get("ALCHEMY_KEY");
const API_KEY = vars.get("ETHERSCAN_KEY");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks:{
    sepolia:{
      url: "https://eth-sepolia.g.alchemy.com/v2/" + ALCHEMY,
      accounts:[SECRET_KEY]
    },
 
  },
  etherscan: {
      
    apiKey: {
      sepolia: API_KEY
    }
  }
};
