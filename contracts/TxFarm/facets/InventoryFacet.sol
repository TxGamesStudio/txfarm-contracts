// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";
import {InventoryStorage} from "../../shared/storage/InventoryStorage.sol";
import {LandStorage} from "../../shared/storage/LandStorage.sol";
import {CraftingStorage } from "../../shared/storage/CraftingStorage.sol";

contract InventoryFacet is Modifiers {

    struct SeedInventoryItem {
        uint256 seedId;
        uint256 quantity;
    }

    struct FarmSupplyInventoryItem {
        uint256 farmSupplyId;
        uint256 quantity;
    }

    struct PlantProducedInventoryItem {
        uint256 seedId;
        uint256 quantity;
    }

    function getSeedInventoryItems(address _owner) external view returns (SeedInventoryItem[] memory) {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        LandStorage storage ls = LibAppStorage.landStorage();
        SeedInventoryItem[] memory seedInventoryItems = new SeedInventoryItem[](ls.seeds.length);
        for(uint256 i; i < ls.seeds.length; i++) {
            seedInventoryItems[i].seedId = ls.seeds[i].id;
            seedInventoryItems[i].quantity = is_.seedQuantities[_owner][ls.seeds[i].id];
        }
        return seedInventoryItems;
    }

    function getFarmSupplyInventoryItems(address _owner) external view returns (FarmSupplyInventoryItem[] memory) {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        uint32 farmSupplyLength = 5;
        FarmSupplyInventoryItem[] memory farmSupplyInventoryItems = new FarmSupplyInventoryItem[](farmSupplyLength);
        for(uint32 i; i < farmSupplyLength; i++) {
            farmSupplyInventoryItems[i].farmSupplyId = i;
            farmSupplyInventoryItems[i].quantity = is_.farmSupplyQuantities[_owner][i];
        }
        return farmSupplyInventoryItems;
    }

    function getPlantProducedInventoryItems(address _owner) external view returns (PlantProducedInventoryItem[] memory) {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        LandStorage storage ls = LibAppStorage.landStorage();
        PlantProducedInventoryItem[] memory producedInventoryItems = new PlantProducedInventoryItem[](ls.seeds.length);
        for(uint256 i; i < ls.seeds.length; i++) {
            producedInventoryItems[i].seedId = ls.seeds[i].id;
            producedInventoryItems[i].quantity = is_.plantProducedQuantities[_owner][ls.seeds[i].id];
        }
        return producedInventoryItems;
    }
}