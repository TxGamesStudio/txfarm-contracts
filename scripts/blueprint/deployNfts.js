const { ethers } = require('hardhat');

async function deployNfts( diamondContract) {
  const MINTER_ROLE = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";

  let TxFarmLandFactory = await ethers.getContractFactory("TxFarmLand");
  let TxFarmLand = await TxFarmLandFactory.deploy();
  await TxFarmLand.deployed();
  console.log("TxFarmLand NFT deployed to:", TxFarmLand.address);
  await TxFarmLand.grantRole(MINTER_ROLE, diamondContract);

  let TxFarmCharacterFactory = await ethers.getContractFactory("TxFarmCharacter");
  let TxFarmCharacter = await TxFarmCharacterFactory.deploy();
  await TxFarmCharacter.deployed();
  console.log("TxFarmCharacter NFT deployed to:", TxFarmCharacter.address);
  await TxFarmCharacter.grantRole(MINTER_ROLE, diamondContract);
  return {
    TxFarmLand: TxFarmLand.address,
    TxFarmCharacter: TxFarmCharacter.address
  }
}

exports.deployNfts = deployNfts;