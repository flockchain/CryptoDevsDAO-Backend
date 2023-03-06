require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const QUICKNODE_HTTP_URL = process.env.QUICKNODE_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",
  networks: {
    goerli: {
      url: "https://delicate-solemn-mound.ethereum-goerli.discover.quiknode.pro/14d7d39436305075567250299f9ae4fccbd0af34/",
      accounts: [PRIVATE_KEY],
    },
  },
};
