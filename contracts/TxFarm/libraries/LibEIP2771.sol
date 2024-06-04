// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {EIP2771Storage} from "../../shared/storage/EIP2771Storage.sol";
import {LibAppStorage} from "./LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";

library LibEIP2771 {
    function setTrustedForwarder(address _trustedForwarder, bool _isTrusted) internal {
        EIP2771Storage storage eip2771Storage = LibAppStorage.eip2771Storage();
        eip2771Storage.trustedForwarders[_trustedForwarder] = _isTrusted;
    }

    function isTrustedForwarder(address forwarder) internal view returns (bool) {
        return LibAppStorage.eip2771Storage().trustedForwarders[forwarder];
    }

    function msgSender() internal view returns (address payable signer) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            assembly {
                signer := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            signer = payable(msg.sender);
        }
    }

    function msgData() internal view returns (bytes calldata ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}
