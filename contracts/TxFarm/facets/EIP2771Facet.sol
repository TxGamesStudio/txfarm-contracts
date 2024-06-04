// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {EIP2771Storage} from "../../shared/storage/EIP2771Storage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";

contract EIP2771Facet is Modifiers {
    function setTrustedForwarder(address _trustedForwarder, bool _isTrusted) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        EIP2771Storage storage eip2771Storage = LibAppStorage.eip2771Storage();
        eip2771Storage.trustedForwarders[_trustedForwarder] = _isTrusted;
    }

    function isTrustedForwarder(address forwarder) external view returns (bool) {
        return LibAppStorage.eip2771Storage().trustedForwarders[forwarder];
    }
}
