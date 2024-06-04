// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {Land, Seed} from "../../shared/storage/LandStorage.sol";
import {CurrencyStorage} from "../../shared/storage/CurrencyStorage.sol";
import {LibRegistry} from "./LibRegistry.sol";

library LibCurrency {
    event SeedBought(uint256 indexed _seedId, uint256 _amount, address _buyer);

    function airdropCurrency(address _receiver, uint256 _amount) internal {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        cs.balances[_receiver] += _amount;
    }

    function getCurrencyBalance(address _address) internal view returns (uint256) {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        return cs.balances[_address];
    }

    function transferCurrency(address _to, uint256 _amount) internal {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        require(cs.balances[LibRegistry.playerAccount()] >= _amount, "LibCurrency: not enough funds");
        cs.balances[LibRegistry.playerAccount()] -= _amount;
        cs.balances[_to] += _amount;
    }
}
