// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMeta {
    uint8 internal constant META_SEMI_NFT_BIT_COUNT = 16;
    uint8 internal constant META_NFT_BIT_COUNT = 16;
    uint256 internal constant META_TOTAL_SEMI_NFT_TOKEN = uint256(2 ** META_SEMI_NFT_BIT_COUNT);
    uint256 internal constant META_TOTAL_NFT_TOKEN = uint256(2 ** META_NFT_BIT_COUNT);

    uint8 internal constant META_ID_TOKEN_SCROLL = 0;
    uint8 internal constant META_ID_TOKEN_DUST = 1;

    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender_ = msg.sender;
        }
    }
}
