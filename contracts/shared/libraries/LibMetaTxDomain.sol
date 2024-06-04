// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct EIP712DomainData {
    /* solhint-disable var-name-mixedcase */
    bytes32 CACHED_DOMAIN_SEPARATOR;
    uint256 CACHED_CHAIN_ID;
    address CACHED_THIS;

    bytes32 HASHED_NAME;
    bytes32 HASHED_VERSION;
    bytes32 TYPE_HASH;
}

struct MetaPackedData {
    address operator;
    address from;
    uint256 nonce;
    uint64 expiredAt;
    bytes4 selector;
    bytes data;
}