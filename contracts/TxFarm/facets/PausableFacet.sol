// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";

contract PausableFacet is Modifiers {
    function pause() external onlyRole(LibAccessControl.OP_ROLE) whenNotPaused {
        LibAppStorage.pausableStorage().paused = true;
    }

    function unpause() external onlyRole(LibAccessControl.OP_ROLE) whenPaused {
        LibAppStorage.pausableStorage().paused = false;
    }
}
