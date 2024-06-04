// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {Item, ItemsStorage, ItemType, Position, Size} from "../../shared/storage/ItemsStorage.sol";
import {Land, LandStorage, MapPosition} from "../../shared/storage/LandStorage.sol";
import {InventoryStorage} from "../../shared/storage/InventoryStorage.sol";
import {LibLand} from "./LibLand.sol";
import {LibRegistry} from "./LibRegistry.sol";
import {Bits} from "./Bits.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ConfigStorage } from "../../shared/storage/ConfigStorage.sol";
library LibItems {
    using Bits for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    function addItems(
        Item[] memory _items,
        uint256 _landId,
        address _owner
    ) internal returns (uint256[] memory ids) {
        ItemsStorage storage _is = LibAppStorage.itemsStorage();
        InventoryStorage storage ivs = LibAppStorage.inventoryStorage();
        uint256 length = _items.length;
        ids = new uint256[](length);
        for (uint256 i; i < length; i++) {
            _items[i].id = _is.items.length;
            _is.items.push(_items[i]);
            ids[i] = _is.items.length - 1;
            if(_items[i].position == Position.Inventory) {
                ivs.userInventoryItemIds[_owner].add(ids[i]);
            } else {
                Land storage land = LibAppStorage.landStorage().lands[_landId];
                land.holdingItemIds.add(ids[i]);
            }
        }
    }

    struct DropItemType {
        ItemType itemType;
        uint256 quantity;
    }

    struct DropItemInitPosition {
        uint8 x;
        uint8 y;
    }

    function dropWelcomeItems(
        address _receiver,
        uint256 _landId,
        uint32 _landMapId
    ) internal returns (uint256[] memory ids) {
        ItemsStorage storage _is = LibAppStorage.itemsStorage();
        LandStorage storage _ls = LibAppStorage.landStorage();
        Land storage land = _ls.lands[_landId];
        Item[] memory welcomeItems = new Item[](
            _is.welcomeItemInitPositionX[_landMapId].length
        );
        uint256 welcomeItemsIndex;
        uint256[] memory emptyArray = new uint256[](0);
        for (uint256 i; i < _is.welcomeItemTypes[_landMapId].length; i++) {
            for (uint256 j; j < _is.welcomeItemQuantities[_landMapId][i]; j++) {
                welcomeItems[welcomeItemsIndex] = Item(
                    0,
                    uint32(_is.welcomeItemTypes[_landMapId][i]),
                    emptyArray,
                    emptyArray,
                    Position.OnLand,
                    _is.welcomeItemIsRotated[_landMapId][welcomeItemsIndex],
                    _landId
                );
                welcomeItemsIndex++;
            }
        }
        ids = addItems(welcomeItems, _landId, _receiver);
        for (uint256 i; i < ids.length; i++) {
            land.plots[_is.welcomeItemInitPositionX[_landMapId][i]][
                _is.welcomeItemInitPositionY[_landMapId][i]
            ] = ids[i];
            // setPlotsFilled(
            //     land,
            //     _is.welcomeItemInitPositionX[i],
            //     _is.welcomeItemInitPositionY[i],
            //     _is.sizes[uint32(welcomeItems[i].itemType)].width,
            //     _is.sizes[uint32(welcomeItems[i].itemType)].height
            // );
        }

        return ids;
    }

    function getOwningItemIds(address _owner) internal view returns (uint256[] memory) {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        LandStorage storage ls = LibAppStorage.landStorage();
        uint256[] memory landIds = LibLand.getLandsOfOwner(_owner);
        uint256 totalItems;
        for (uint256 i = 0; i < landIds.length; i++) {
            uint256 holdingItemCount = ls.lands[landIds[i]].holdingItemIds.length();
            totalItems += holdingItemCount;
        }
        totalItems += is_.userInventoryItemIds[_owner].length();
        uint256[] memory itemIds = new uint256[](totalItems);
        uint256 index;
        for (uint256 i = 0; i < landIds.length; i++) {
            EnumerableSet.UintSet storage holdingItemIds = ls.lands[landIds[i]].holdingItemIds;
            for (uint256 j = 0; j < holdingItemIds.length(); j++) {
                itemIds[index] = holdingItemIds.at(j);
                index++;
            }
        }
        for (uint256 i = 0; i < is_.userInventoryItemIds[_owner].length(); i++) {
            itemIds[index] = is_.userInventoryItemIds[_owner].at(i);
            index++;
        }
        return itemIds;
    }

    // function clearPlotsFilled(
    //     Land storage _land,
    //     uint8 _plotPositionX,
    //     uint8 _plotPositionY,
    //     uint8 _width,
    //     uint8 _height
    // ) internal {
    //     for (uint8 i; i < _width; i++) {
    //         uint256 newRowFilledValue = _land.plotFilled[_plotPositionX + i];
    //         for (uint8 j; j < _height; j++) {
    //             newRowFilledValue = newRowFilledValue.clearBit(
    //                 255 - (_plotPositionY + j)
    //             );
    //         }
    //         _land.plotFilled[_plotPositionX + i] = newRowFilledValue;
    //     }
    // }

    // function setPlotsFilled(
    //     Land storage _land,
    //     uint8 _plotPositionX,
    //     uint8 _plotPositionY,
    //     uint8 _width,
    //     uint8 _height
    // ) internal {
    //     for (uint8 i; i < _width; i++) {
    //         uint256 newRowFilledValue = _land.plotFilled[_plotPositionX + i];
    //         for (uint8 j; j < _height; j++) {
    //             newRowFilledValue = newRowFilledValue.setBit(
    //                 255 - (_plotPositionY + j)
    //             );
    //         }
    //         _land.plotFilled[_plotPositionX + i] = newRowFilledValue;
    //     }
    // }

    function setMapPositions(
        uint256 _landId,
        MapPosition[] memory _removeMapPositions,
        MapPosition[] memory _insertMapPositions
    ) internal {
        // require(_mapPositions.length > 0, "LibItems: mapPositions empty");

        ItemsStorage storage _is = LibAppStorage.itemsStorage();
        InventoryStorage storage ivs = LibAppStorage.inventoryStorage();
        LandStorage storage _ls = LibAppStorage.landStorage();
        Land storage land = _ls.lands[_landId];
        require(
            LibLand.getLandOwner(_landId) == LibRegistry.playerAccount(),
            "LibItems: not land owner"
        );
        for (uint i; i < _removeMapPositions.length; i++) {
            Item storage item = _is.items[_removeMapPositions[i].itemId];
            unplaceItem(
                land.id,
                _removeMapPositions[i].x,
                _removeMapPositions[i].y,
                item.id,
                _removeMapPositions[i].isRotated
            );
            item.isRotated = false;  
        }
        for (uint i; i < _insertMapPositions.length; i++) {
            Item storage item = _is.items[_insertMapPositions[i].itemId];
            require(
                ivs.userInventoryItemIds[LibLand.getLandOwner(_landId)].contains(item.id),
                "LibItems: item not in owner inventory"
            );
            item.isRotated = _insertMapPositions[i].isRotated;
            placeItem(
                land.id,
                _insertMapPositions[i].x,
                _insertMapPositions[i].y,
                item.id,
                _insertMapPositions[i].isRotated
            );
        }
    }

    function placeItem(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _itemId,
        bool _isRotated
    ) internal {
        ItemsStorage storage _is = LibAppStorage.itemsStorage();
        InventoryStorage storage ivs = LibAppStorage.inventoryStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[_itemId];
        address owner = LibLand.getLandOwner(_landId);
        require(
            ivs.userInventoryItemIds[owner].contains(_itemId),
            "LibItems: item not in owner inventory"
        );
        require(
            item.position == Position.Inventory,
            "LibItems: item not in inventory"
        );
        item.position = Position.OnLand;
        item.belongsToLandId = _landId;
        Size memory size = _is.sizes[item.itemType];
        /// @dev check if item is rotated
        if(_isRotated) {
            size = Size(size.height, size.width);
        }
        item.isRotated = _isRotated;
        require(
            _plotPositionX + size.width <= 100 &&
                _plotPositionY + size.height <= 100,
            "LibItems: item out of bounds"
        );
        for (uint8 i; i < size.width; i++) {
            for (uint8 j; j < size.height; j++) {
                require(
                    LibLand.isPlotActive(
                        land,
                        _plotPositionX + i,
                        _plotPositionY + j
                    ),
                    "LibItems: plot not active"
                );
                // require(
                //     !LibLand.isPlotFilled(
                //         land,
                //         _plotPositionX + i,
                //         _plotPositionY + j
                //     ),
                //     "LibItems: plot already filled"
                // );
            }
        }
        ///@dev set plot filled in map
        // setPlotsFilled(
        //     land,
        //     _plotPositionX,
        //     _plotPositionY,
        //     size.width,
        //     size.height
        // );

        land.plots[_plotPositionX][_plotPositionY] = _itemId;
        ///@dev Remove id from inventory
        ivs.userInventoryItemIds[owner].remove(_itemId);
        ///@dev Add to holding item ids
        land.holdingItemIds.add(_itemId);
    }

    function unplaceItem(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _itemId,
        bool _isRotated
    ) internal {
        ItemsStorage storage _is = LibAppStorage.itemsStorage();
        InventoryStorage storage ivs = LibAppStorage.inventoryStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[_itemId];
        require(item.position == Position.OnLand, "LibItems: item not in yard");
        address owner = LibLand.getLandOwner(_landId);
        item.position = Position.Inventory;
        item.belongsToLandId = 0;
        require(
            LibLand.isPlotActive(land, _plotPositionX, _plotPositionY),
            "LibItems: plot not active"
        );
        require(
            land.plots[_plotPositionX][_plotPositionY] > 1,
            "LibItems: plot empty"
        );
        require(
            land.plots[_plotPositionX][_plotPositionY] == _itemId,
            "LibItems: item not in plot"
        );
        require(
            land.holdingItemIds.contains(_itemId),
            "LibItems: item not in holding item ids"
        );
        Size memory size = _is.sizes[item.itemType];
        /// @dev check if item is rotated
        if(_isRotated) {
            size = Size(size.height, size.width);
        }
        require(
            _plotPositionX + size.width <= 100 &&
                _plotPositionY + size.height <= 100,
            "LibItems: item out of bounds"
        );
        ///@dev set clear plot filled in map
        // clearPlotsFilled(
        //     land,
        //     _plotPositionX,
        //     _plotPositionY,
        //     size.width,
        //     size.height
        // );

        land.plots[_plotPositionX][_plotPositionY] = 0;
        ///@dev Push back id to inventory
        ivs.userInventoryItemIds[owner].add(_itemId);
        ///@dev Remove from holding item ids
        land.holdingItemIds.remove(_itemId);
    }

}
