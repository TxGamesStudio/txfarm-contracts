const {setMainConfig} = require('./blueprint/setMainConfig');

async function setDefaultConfig({ blueprintAcc, minterAcc, opAcc, finalcialAcc, signerAcc }, gachaAddress) {
  console.log("Start setting default config...");
  await setMainConfig(blueprintAcc, gachaAddress);
  console.log(`Done!`);
  console.log("------------------");
}

exports.setDefaultConfig = setDefaultConfig;