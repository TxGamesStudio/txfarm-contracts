/* global ethers */
/* eslint prefer-const: "off" */
const hre = require("hardhat");
const diamond = require('../js/diamond-util/src/index.js')

async function upgrade(diamondAddress, faceName, selectorsToRemove) {
    console.log(arguments)

    const accounts = await hre.ethers.getSigners()

    await diamond.upgradeWithNewFacets({
        diamondAddress,
        facetNames: [faceName],
        selectorsToRemove
    })
}

exports.upgrade = upgrade
