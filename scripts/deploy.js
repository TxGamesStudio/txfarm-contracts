/* global ethers */
/* eslint prefer-const: "off" */

const hre = require("hardhat");
const { deployTxFarm } = require('./deployTxFarm')
const { setDefaultConfig } = require('./setDefaultConfig')
const dotenv = require('dotenv');

async function deploy() {
    const accounts = await hre.ethers.getSigners()
    let owner, blueprintAcc, minterAcc, opAcc, financialAcc, signerAcc;

    if (hre.network.name == "redstone") {
        owner = blueprintAcc = minterAcc = opAcc = financialAcc = signerAcc = accounts[0].address
    } else {
        if (accounts.length < 6) {
            throw new Error('Please set 6 accounts in .env file');
        }
        owner = accounts[0].address;
        blueprintAcc = accounts[1].address;
        minterAcc = accounts[2].address;
        opAcc = accounts[3].address;
        financialAcc = accounts[4].address;
        signerAcc = accounts[5].address;
    }

    let {
        diamondAddress: businessAddress
    } = await deployTxFarm({
        accounts: [
            owner,
            blueprintAcc,
            minterAcc,
            opAcc,
            financialAcc,
            signerAcc
        ]
    });
    if (hre.network.name == "redstone") {
        await setDefaultConfig(
            {
                blueprintAcc: accounts[0],
                minterAcc: accounts[0],
                opAcc: accounts[0],
                financialAcc: accounts[0],
                signerAcc: accounts[0]
            },
            businessAddress
        );
    } else {
        await setDefaultConfig(
            {
                blueprintAcc: accounts[1],
                minterAcc: accounts[2],
                opAcc: accounts[3],
                financialAcc: accounts[4],
                signerAcc: accounts[5]
            },
            businessAddress
        );
    }

    return {
        businessAddress: businessAddress
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deploy()
        .then(() => process.exit(0))
        .catch(error => {
            console.error(error)
            process.exit(1)
        })
}

exports.deploy = deploy
