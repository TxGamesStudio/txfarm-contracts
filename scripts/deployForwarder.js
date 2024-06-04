const hre = require("hardhat");
const dotenv = require('dotenv');

async function deploy() {
  const accounts = await hre.ethers.getSigners()
  const Forwarder = await hre.ethers.getContractFactory("Forwarder");
  const forwarder = await Forwarder.deploy();
  await forwarder.deployed();
  // await hre.tenderly.verify({

  //   name: "Forwarder",
  //   address: forwarder.address,
  // })
  console.log("Forwarder deployed to:", forwarder.address);
  console.log(`RequestTypeHash: 0xb91ae508e6f0e8e33913dec60d2fdcb39fe037ce56198c70a7927d7cd813fd96`);
  let tx = await forwarder.registerDomainSeparator(
    "TxFarm",
    "1.0"
  );
  let receipt = await tx.wait();
  console.log(`DomainSeparator: ${receipt.events[0].args.domainSeparator}`);
}
if (require.main === module) {
  hre.run("compile").then(deploy)
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployForwarder = deploy