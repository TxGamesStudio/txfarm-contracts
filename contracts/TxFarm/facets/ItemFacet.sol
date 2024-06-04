// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibLand} from "../libraries/LibLand.sol";
import {LibItems} from "../libraries/LibItems.sol";
import {LibRegistry} from "../libraries/LibRegistry.sol";
import {LandStorage, Land, Seed, Animal, Plant, MapPosition, AnimalKind} from "../../shared/storage/LandStorage.sol";
import {Item, ItemType, ItemsStorage, Position, Size, ItemCategory} from "../../shared/storage/ItemsStorage.sol";
import {InventoryStorage} from "../../shared/storage/InventoryStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ItemFacet is Modifiers {
    struct ItemResponse {
        uint256 id;
        ItemType itemType;
        uint256[] plantIds;
        uint256[] animalIds;
        Position position;
        ItemCategory category;
        uint32 harvestedTimes;
        bool isRotated;
        uint256 belongsToLandId;
    }

    function getMaxCropHarvestableTimes() external view returns (uint32) {
        return LibAppStorage.itemsStorage().maxCropHarvestableTimes;
    }

    function getItemsOfOwner(
        address _owner
    ) external view returns (uint256[] memory) {
        return LibItems.getOwningItemIds(_owner);
    }

    function getItems(
        uint256[] memory itemIds
    ) external view returns (ItemResponse[] memory) {
        ItemsStorage storage itemS = LibAppStorage.itemsStorage();
        ItemResponse[] memory items = new ItemResponse[](itemIds.length);
        for (uint256 i; i < itemIds.length; i++) {
            Item storage item = itemS.items[itemIds[i]];
            items[i] = ItemResponse(
                item.id,
                ItemType(item.itemType),
                item.plantIds,
                item.animalIds,
                item.position,
                itemS.itemCategories[item.itemType],
                itemS.harvestedTimes[item.id],
                item.isRotated,
                item.belongsToLandId
            );
        }
        return items;
    }

    function getPlants(address _owner) external view returns (Plant[] memory) {
        ItemsStorage storage itemS = LibAppStorage.itemsStorage();
        LandStorage storage ls = LibAppStorage.landStorage();
        uint256[] memory itemIds = LibItems.getOwningItemIds(_owner);
        uint256 plantCount;
        for (uint256 i; i < itemIds.length; i++) {
            plantCount += itemS.items[itemIds[i]].plantIds.length;
        }
        Plant[] memory plants = new Plant[](plantCount);
        uint256 plantIndex;
        for (uint256 i; i < itemIds.length; i++) {
            uint256[] memory plantIds = itemS.items[itemIds[i]].plantIds;
            for (uint256 j; j < plantIds.length; j++) {
                plants[plantIndex] = ls.plants[plantIds[j]];
                plantIndex++;
            }
        }
        return plants;
    }
}
