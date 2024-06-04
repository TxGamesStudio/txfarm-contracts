// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";
import {LandStorage, Land, Seed} from "../../shared/storage/LandStorage.sol";
import {LibStore} from "../libraries/LibStore.sol";
import {StoreStorage} from "../../shared/storage/StoreStorage.sol";
import {FarmSupplyCategory} from "../../shared/storage/InventoryStorage.sol";
import {ItemType} from "../../shared/storage/ItemsStorage.sol";

struct StoreSeed {
    uint256 id;
    uint256 price;
    uint64 growthDuration;
    uint256 availableQuantity;
    bool isBuyable;
}

struct FarmSupply {
    uint256 id;
    uint256 price;
    uint256 availableQuantity;
    bool isBuyable;
}

struct StoreItemType {
    uint256 id;
    uint256 price;
    uint256 availableQuantity;
    bool isBuyable;
}

contract StoreFacet is Modifiers {
    event SeedBought(uint256 indexed _seedId, uint256 _amount, address _buyer);
    event ItemsBought(
        uint32 indexed _itemTypeId,
        uint256 _amount,
        address _buyer,
        uint256[] _newItemIds
    );
    event FarmSupplyBought(
        FarmSupplyCategory indexed _farmSupplyId,
        uint256 _amount,
        address _buyer
    );
    event SeedSold(uint256 indexed _seedId, uint256 _amount, address _seller);
    event ItemsSold(
        uint32 indexed _itemTypeId,
        uint256 _amount,
        address _seller
    );
    event FarmSupplySold(
        FarmSupplyCategory indexed _farmSupplyId,
        uint256 _amount,
        address _seller
    );

    function buySeed(uint256 _seedId, uint256 _amount) external whenNotPaused {
        LibStore.buySeed(_seedId, _amount);
    }

    function sellSeed(uint256 _seedId, uint256 _amount) external whenNotPaused {
        LibStore.sellSeed(_seedId, _amount);
    }

    function buyFarmSupply(
        FarmSupplyCategory _farmSupplyId,
        uint256 _amount
    ) external whenNotPaused {
        LibStore.buyFarmSupply(_farmSupplyId, _amount);
    }

    function sellFarmSupply(
        FarmSupplyCategory _farmSupplyId,
        uint256 _amount
    ) external whenNotPaused {
        LibStore.sellFarmSupply(_farmSupplyId, _amount);
    }

    function buyItem(
        ItemType _itemTypeId,
        uint256 _amount
    ) external whenNotPaused {
        LibStore.buyItem(_itemTypeId, _amount);
    }

    function sellItems(uint256[] memory _itemIds) external whenNotPaused {
        LibStore.sellItems(_itemIds);
    }

    function airdropSeed(
        address _receiver,
        uint256 _seedId,
        uint256 _amount
    ) external onlyRole(LibAccessControl.OP_ROLE) {
        LibStore.airdropSeed(_receiver, _seedId, _amount);
    }

    function sellPlantProduction(
        uint256 _seedId,
        uint256 _amount
    ) external whenNotPaused() {
        LibStore.sellPlantProduction(_seedId, _amount);
    }
    
    function airdropFarmSupply(
        address _receiver,
        FarmSupplyCategory _farmSupplyId,
        uint256 _amount
    ) external onlyRole(LibAccessControl.OP_ROLE) {
        LibStore.airdropFarmSupply(_receiver, _farmSupplyId, _amount);
    }

    function getStoreSeeds() external view returns (StoreSeed[] memory) {
        LandStorage storage ls = LibAppStorage.landStorage();
        StoreStorage storage ss = LibAppStorage.storeStorage();
        StoreSeed[] memory storeSeeds = new StoreSeed[](ls.seeds.length);
        for (uint256 i; i < ls.seeds.length; i++) {
            storeSeeds[i].id = ls.seeds[i].id;
            storeSeeds[i].price = ls.seeds[i].price;
            storeSeeds[i].growthDuration = ls.seeds[i].growthDuration;
            storeSeeds[i].availableQuantity = ss.availableSeedQuantities[
                ls.seeds[i].id
            ];
            storeSeeds[i].isBuyable = ss.isSeedBuyables[ls.seeds[i].id];
        }
        return storeSeeds;
    }

    function getStoreFarmSupplies()
        external
        view
        returns (FarmSupply[] memory)
    {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        FarmSupply[] memory storeFarmSupplies = new FarmSupply[](
            uint(type(FarmSupplyCategory).max) + 1
        );
        for (uint32 i; i < uint32(type(FarmSupplyCategory).max) + 1; i++) {
            storeFarmSupplies[i].id = i;
            storeFarmSupplies[i].price = ss.farmSupplyPrices[i];
            storeFarmSupplies[i].availableQuantity = ss
                .availableFarmSupplyQuantities[i];
            storeFarmSupplies[i].isBuyable = ss.isFarmSupplyBuyables[i];
        }
        return storeFarmSupplies;
    }

    function getStoreItems() external view returns (StoreItemType[] memory) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        StoreItemType[] memory storeItemTypes = new StoreItemType[](
            uint(type(ItemType).max) + 1
        );
        for (uint32 i; i < uint32(type(ItemType).max) + 1; i++) {
            storeItemTypes[i].id = i;
            storeItemTypes[i].price = ss.itemTypePrices[i];
            storeItemTypes[i].availableQuantity = ss
                .availableItemTypeQuantities[i];
            storeItemTypes[i].isBuyable = ss.isItemTypeBuyables[i];
        }
        return storeItemTypes;
    }

    function getSellReturnRate() external view returns (uint256) {
        return LibAppStorage.storeStorage().sellRate;
    }
}
