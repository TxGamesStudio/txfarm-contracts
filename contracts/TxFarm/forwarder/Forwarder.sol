// solhint-disable not-rely-on-time
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// #if ENABLE_CONSOLE_LOG
import "hardhat/console.sol";
// #endif

import "./IForwarder.sol";

/**
 * @title The Forwarder Implementation
 * @notice This implementation of the `IForwarder` interface uses ERC-712 signatures and stored nonces for verification.
 */
contract Forwarder is IForwarder, ERC165, Ownable {
    using ECDSA for bytes32;

    event ExecutionResult(bool success, bytes ret);
    event ExecutionFailed(string reason);
    event MulticallResult(uint index, bool success, bytes ret);

    address private constant DRY_RUN_ADDRESS = 0x0000000000000000000000000000000000000000;

    string public constant GENERIC_PARAMS = "address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,uint256 validUntilTime";

    string public constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";

    mapping(bytes32 => bool) public typeHashes;
    mapping(bytes32 => bool) public domains;

    // Nonces of senders, used to prevent replay attacks
    mapping(uint256 => bool) public nonces;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    constructor() {
        string memory requestType = string(abi.encodePacked("ForwardRequest(", GENERIC_PARAMS, ")"));
        registerRequestTypeInternal(requestType);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IForwarder).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IForwarder
    function verify(
        ForwardRequest calldata req,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig
    ) external view override {
        _verifyNonce(req);
        _verifySig(req, domainSeparator, requestTypeHash, suffixData, sig);
    }

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    /// @inheritdoc IForwarder
    function execute(
        ForwardRequest calldata req,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig
    ) external payable override returns (bool success, bytes memory ret) {
        _verifySig(req, domainSeparator, requestTypeHash, suffixData, sig);
        _verifyAndUpdateNonce(req);

        require(req.validUntilTime == 0 || req.validUntilTime > block.timestamp, "FWD: request expired");

        uint256 gasForTransfer = 0;
        if (req.value != 0) {
            gasForTransfer = 40000; //buffer in case we need to move eth after the transaction.
        }
        bytes memory callData = abi.encodePacked(req.data, req.from);
        require((gasleft() * 63) / 64 >= req.gas + gasForTransfer, "FWD: insufficient gas");
        // solhint-disable-next-line avoid-low-level-calls
        (success, ret) = req.to.call{gas: req.gas, value: req.value}(callData);
        
        emit ExecutionResult(success, ret);
        if(!success) {
            emit ExecutionFailed(_getRevertMsg(ret));
        }
        // #if ENABLE_CONSOLE_LOG
        console.log("execute result: success: %s ret:", success);
        console.logBytes(ret);
        // #endif

        // if (req.value != 0 && address(this).balance > 0) {
        //     // can't fail: req.from signed (off-chain) the request, so it must be an EOA...
        //     payable(req.from).transfer(address(this).balance);
        // }

        return (success, ret);
    }

    function _verifyNonce(ForwardRequest calldata req) internal view {
        require(nonces[req.nonce] == false, "FWD: nonce mismatch");
    }

    function _verifyAndUpdateNonce(ForwardRequest calldata req) internal {
        require(nonces[req.nonce] == false, "FWD: nonce mismatch");
        nonces[req.nonce] = true;
    }

    /// @inheritdoc IForwarder
    function registerRequestType(string calldata typeName, string calldata typeSuffix) external onlyOwner {
        for (uint256 i = 0; i < bytes(typeName).length; i++) {
            bytes1 c = bytes(typeName)[i];
            require(c != "(" && c != ")", "FWD: invalid typename");
        }

        string memory requestType = string(abi.encodePacked(typeName, "(", GENERIC_PARAMS, ",", typeSuffix));
        registerRequestTypeInternal(requestType);
    }

    /// @inheritdoc IForwarder
    function registerDomainSeparator(string calldata name, string calldata version) external onlyOwner {
        uint256 chainId;
        /* solhint-disable-next-line no-inline-assembly */
        assembly {
            chainId := chainid()
        }

        bytes memory domainValue = abi.encode(
            keccak256(bytes(EIP712_DOMAIN_TYPE)),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId,
            address(this)
        );

        bytes32 domainHash = keccak256(domainValue);

        domains[domainHash] = true;
        emit DomainRegistered(domainHash, domainValue);
    }

    function registerRequestTypeInternal(string memory requestType) internal {
        bytes32 requestTypehash = keccak256(bytes(requestType));
        typeHashes[requestTypehash] = true;
        emit RequestTypeRegistered(requestTypehash, requestType);
    }

    function _verifySig(
        ForwardRequest calldata req,
        bytes32 domainSeparator,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig
    ) internal view virtual {
        require(domains[domainSeparator], "FWD: unregistered domain sep.");
        require(typeHashes[requestTypeHash], "FWD: unregistered typehash");
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, keccak256(_getEncoded(req, requestTypeHash, suffixData))));
        // solhint-disable-next-line avoid-tx-origin
        require(tx.origin == DRY_RUN_ADDRESS || digest.recover(sig) == req.from, "FWD: signature mismatch");
    }

    /**
     * @notice Creates a byte array that is a valid ABI encoding of a request of a `RequestType` type. See `execute()`.
     */
    function _getEncoded(ForwardRequest calldata req, bytes32 requestTypeHash, bytes calldata suffixData) public pure returns (bytes memory) {
        // we use encodePacked since we append suffixData as-is, not as dynamic param.
        // still, we must make sure all first params are encoded as abi.encode()
        // would encode them - as 256-bit-wide params.
        return
            abi.encodePacked(
                requestTypeHash,
                uint256(uint160(req.from)),
                uint256(uint160(req.to)),
                req.value,
                req.gas,
                req.nonce,
                keccak256(req.data),
                req.validUntilTime,
                suffixData
            );
    }

    function multiCall(bytes[] calldata data) external returns (bytes[] memory) {
        bytes[] memory results = new bytes[](data.length);

        for (uint i = 0; i <  data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            // require(success, "call failed");
            emit MulticallResult(i, success, result);
            results[i] = result;
        }

        return results;
    }
}
