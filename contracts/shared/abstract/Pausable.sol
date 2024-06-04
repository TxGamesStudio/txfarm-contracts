// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { LibMeta } from "../libraries/LibMeta.sol";
import { PausableStorage } from "../storage/PausableStorage.sol";

abstract contract Pausable {

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function paused() public view returns (bool) {
        PausableStorage storage s = _getPausableStorage();
        return s.paused;
    }

    function _pause() internal whenNotPaused {
        PausableStorage storage s = _getPausableStorage();
        s.paused = true;
        emit Paused(LibMeta.msgSender());
    }

    function _unpause() internal whenPaused {
        PausableStorage storage s = _getPausableStorage();
        s.paused = false;
        emit Unpaused(LibMeta.msgSender());
    }

    function _getPausableStorage() internal view virtual returns (PausableStorage storage);
}