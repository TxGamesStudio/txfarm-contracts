pragma solidity ^0.8.0;
import {LibMetaTransaction} from "../../../contracts/TxFarm/libraries/LibMetaTransaction.sol";
import {EIP712DomainData, MetaPackedData} from "../../../contracts/shared/libraries/LibMetaTxDomain.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/Test.sol";

abstract contract MetaTxGenerator is Test {
   using ECDSA for bytes32;

    function _buildDomainSeparator(address _diamond) private view returns (bytes32) {
        bytes32 hashedName = keccak256(bytes("TxFarm"));
        bytes32 hashedVersion = keccak256(bytes("1.0"));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        return keccak256(abi.encode(typeHash, hashedName, hashedVersion, block.chainid, _diamond));
    }

    function _domainSeparatorV4(address _diamond) internal view returns (bytes32) {
        return _buildDomainSeparator(_diamond);
    }

    function _hashTypedDataV4(address _diamond, bytes32 structHash) internal view returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(_diamond), structHash);
    }

    function signMetaPackedData(MetaPackedData memory _req, address _diamond, uint256 _signerPK) public view returns(bytes memory) {
       bytes32 _TYPEHASH = keccak256("MetaPackedData(address operator,address from,uint256 nonce,uint64 expiredAt,bytes4 selector,bytes data)");
       bytes32 digest = (
            _hashTypedDataV4(_diamond, keccak256(abi.encode(_TYPEHASH, _req.operator, _req.from, _req.nonce, _req.expiredAt, _req.selector, keccak256(_req.data))))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPK, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        return signature;
    }
}