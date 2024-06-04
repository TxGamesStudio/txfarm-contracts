// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {Seed} from "./LandStorage.sol";
import {FarmSupplyCategory} from "./InventoryStorage.sol";

struct StoreStorage {
    ///@dev avaiable seed in store
    mapping(uint256 => uint256) availableSeedQuantities;

    mapping(uint32 => uint256) farmSupplyPrices;
    ///@dev avaiable farm supply in store
    mapping(uint32 => uint256) availableFarmSupplyQuantities;

    mapping(uint32 => uint256) itemTypePrices;
    mapping(uint32 => uint256) availableItemTypeQuantities;

    mapping(uint32 => bool) isFarmSupplyBuyables;
    mapping(uint256 => bool) isSeedBuyables;
    mapping(uint32 => bool) isItemTypeBuyables;

    uint256 sellRate;
}
