// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library LibRNG {
    function pseudoRandom(uint data) internal view returns (uint) {
        return uint(keccak256(abi.encode(data, msg.sender, block.prevrandao, block.timestamp, blockhash(block.number-1))));
    }

    function randomBool(uint8 shift) internal view returns (bool) {
        return (pseudoRandom(shift) >> shift) & 1 == 1 ? true : false;
    }

    function random(uint16 percentage) internal view returns (bool) {
        require(percentage <= 10000, "maximum value is 10000");
        return pseudoRandom(percentage) % 10000 > percentage;
    }
}