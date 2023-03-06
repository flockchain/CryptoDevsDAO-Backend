// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const { CRYPTODEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {

  // Deploying the FakeNFTMarketplace 
  const FakeNFTMarketplaceUndeployed = await ethers.getContractFactory("FakeNFTMarketplace");
  const fakeNFTMarketplace = await FakeNFTMarketplaceUndeployed.deploy()
  await fakeNFTMarketplace.deployed()

  console.log("FakeNFTMArketplace deployed to: ", fakeNFTMarketplace.address);


  // Deploying CryptoDevsDAO contract
  const CryptoDevsDAOUndeployed = await ethers.getContractFactory("CryptoDevsDAO");
  const cryptoDevsDAO = await CryptoDevsDAOUndeployed.deploy(fakeNFTMarketplace.address, CRYPTODEVS_NFT_CONTRACT_ADDRESS,
  {
    //This is a check if your account has enough ETH
    value: ethers.utils.parseEther("0.1"),
  });
  await cryptoDevsDAO.deployed()

  console.log("CryptoDevsDao deployed to: ", cryptoDevsDAO.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
