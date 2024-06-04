// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";
import {LibCurrency} from "../libraries/LibCurrency.sol";

contract CurrencyFacet is Modifiers {
    function airdropCurrency(address _receiver, uint256 _amount) external onlyRole(LibAccessControl.OP_ROLE) {
        LibCurrency.airdropCurrency(_receiver, _amount);
    }

    function getCurrencyBalance(address _address) external view returns (uint256) {
        return LibCurrency.getCurrencyBalance(_address);
    }

    function transferCurrency(address _to, uint256 _amount) external {
        LibCurrency.transferCurrency(_to, _amount);
    }
}