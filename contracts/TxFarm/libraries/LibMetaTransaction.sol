// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

import { LibAppStorage, AppStorage } from "./LibAppStorage.sol";

import { EIP712DomainData, MetaPackedData } from "../../shared/libraries/LibMetaTxDomain.sol";
import { LibAccessControl } from "../../shared/libraries/LibAccessControl.sol";
import { AccessControlStorage } from "../../shared/storage/AccessControlStorage.sol";

library LibMetaTransaction {
    using BitMaps for BitMaps.BitMap;
    using Address for address;
    using ECDSA for bytes32;

    function initEIP721DomainData(string memory name, string memory version) internal {
        EIP712DomainData storage domainData = LibAppStorage.eip712DomainDataStorage();

        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        domainData.HASHED_NAME = hashedName;
        domainData.HASHED_VERSION = hashedVersion;
        domainData.CACHED_CHAIN_ID = block.chainid;
        domainData.CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        domainData.CACHED_THIS = address(this);
        domainData.TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        EIP712DomainData memory domainData = LibAppStorage.eip712DomainDataStorage();

        if (address(this) == domainData.CACHED_THIS && block.chainid == domainData.CACHED_CHAIN_ID) {
            return domainData.CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(domainData.TYPE_HASH, domainData.HASHED_NAME, domainData.HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    bytes32 private constant _TYPEHASH = keccak256(
        "MetaPackedData(address operator,address from,uint256 nonce,uint64 expiredAt,bytes4 selector,bytes data)"
    );

    function verify(bytes4 selector, MetaPackedData calldata req, bytes memory signature) internal view {
        verify(selector, req, signature, msg.sender);
    }

    function verify(
        bytes4 selector, MetaPackedData calldata req, bytes memory signature, address sender
    ) internal view {
        AccessControlStorage storage acs = LibAppStorage.accessControlStorage();
        require(req.selector == selector, "call wrong function");
        require(req.from == sender, "sender must match");
        require(req.expiredAt >= block.timestamp, "tx is expired");
        require(!LibAppStorage.eip712NonceStorage().used[req.nonce], "nonce is used");
        address signer = _hashTypedDataV4(
            keccak256(abi.encode(
                _TYPEHASH, req.operator, req.from, req.nonce, req.expiredAt, req.selector, keccak256(req.data)
            ))
        ).recover(signature);
        require(signer == req.operator, "invalid signer");
        require(LibAccessControl.hasRole(acs, LibAccessControl.SIGNER_ROLE, signer), "unknown signer");
    }
}