// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {Land, Seed, AnimalKind, LandStorage} from "../../shared/storage/LandStorage.sol";
import {StoreStorage} from "../../shared/storage/StoreStorage.sol";
import {CurrencyStorage} from "../../shared/storage/CurrencyStorage.sol";
import {InventoryStorage, FarmSupplyCategory} from "../../shared/storage/InventoryStorage.sol";
import {LibEIP2771} from "./LibEIP2771.sol";
import {LibLand} from "./LibLand.sol";
import {LibRegistry} from "./LibRegistry.sol";
import {Item, ItemType, Position, ItemsStorage} from "../../shared/storage/ItemsStorage.sol";
import {LibItems} from "./LibItems.sol";
import {CraftingStorage, CraftProduct} from "../../shared/storage/CraftingStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LibStore {
    using EnumerableSet for EnumerableSet.UintSet;

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

    function buySeed(uint256 _seedId, uint256 _amount) internal {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        require(_amount > 0, "LibStore: _amount must be > 0");

        Seed memory seed = LibLand._getSeed(_seedId);
        require(seed.price > 0, "LibStore: seed price not set");
        require(
            ss.availableSeedQuantities[_seedId] >= _amount,
            "LibStore: not enough seeds available"
        );
        ss.availableSeedQuantities[_seedId] -= _amount;
        uint256 totalPrice = seed.price * _amount;
        require(
            cs.balances[LibRegistry.playerAccount()] >= totalPrice,
            "LibStore: not enough funds"
        );
        cs.balances[LibRegistry.playerAccount()] -= totalPrice;
        is_.seedQuantities[LibRegistry.playerAccount()][_seedId] += _amount;
        emit SeedBought(_seedId, _amount, LibRegistry.playerAccount());
    }

    function sellSeed(uint256 _seedId, uint256 _amount) internal {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        require(ss.sellRate > 0, "LibStore: sell rate not set");
        require(_amount > 0, "LibStore: _amount must be > 0");
        require(
            is_.seedQuantities[LibRegistry.playerAccount()][_seedId] >= _amount,
            "LibStore: not enough seeds owned"
        );
        is_.seedQuantities[LibRegistry.playerAccount()][_seedId] -= _amount;
        Seed memory seed = LibLand._getSeed(_seedId);
        uint256 totalReceived = (seed.price * _amount * ss.sellRate) / 100_00;
        cs.balances[LibRegistry.playerAccount()] += totalReceived;
        emit SeedSold(_seedId, _amount, LibRegistry.playerAccount());
    }

    // function sellCraftingProduction(uint256 _craftProductId, uint256 _amount) internal {
    //     InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
    //     CraftingStorage storage cs = LibAppStorage.craftingStorage();
    //     CraftProduct storage craftProduct = cs.craftProducts[_craftProductId];
    //     StoreStorage storage ss = LibAppStorage.storeStorage();
    //     require(craftProduct.id > 0, "LibStore: craft product not found");
    //     require(
    //         is_.craftedProductQuantities[LibRegistry.playerAccount()][_craftProductId] >=
    //             _amount,
    //         "LibStore: not enough crafting production owned"
    //     );
    //     is_.craftedProductQuantities[LibRegistry.playerAccount()][
    //         _craftProductId
    //     ] -= _amount;
    //     uint256 receiveAmount = craftProduct.price * _amount * ss.sellRate / 100_00;
    //     CurrencyStorage storage cs_ = LibAppStorage.currencyStorage();
    //     cs_.balances[LibRegistry.playerAccount()] += receiveAmount;
    // }

    function buyItem(ItemType _itemTypeId, uint256 _amount) internal {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(_amount > 0, "LibStore: _amount must be > 0");
        require(
            ss.itemTypePrices[uint32(_itemTypeId)] > 0,
            "LibStore: item type price not set"
        );
        require(
            ss.availableItemTypeQuantities[uint32(_itemTypeId)] >= _amount,
            "LibStore: not enough item type available"
        );
        uint256 totalPrice = ss.itemTypePrices[uint32(_itemTypeId)] * _amount;
        require(
            cs.balances[LibRegistry.playerAccount()] >= totalPrice,
            "LibStore: not enough funds"
        );
        ss.availableItemTypeQuantities[uint32(_itemTypeId)] -= _amount;
        cs.balances[LibRegistry.playerAccount()] -= totalPrice;
        Item[] memory items = new Item[](_amount);
        for (uint256 i; i < _amount; i++) {
            items[i].itemType = uint32(_itemTypeId);
            items[i].position = Position.Inventory;
        }
        uint256[] memory newItems = LibItems.addItems(items, 0, LibRegistry.playerAccount());

        emit ItemsBought(
            uint32(_itemTypeId),
            _amount,
            LibRegistry.playerAccount(),
            newItems
        );
    }

    function sellItems(uint256[] memory _itemIds) internal {
        for (uint256 i; i < _itemIds.length; i++) {
            sellItem(_itemIds[i]);
        }
    }

    function sellItem(uint256 _itemId) internal {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        ItemsStorage storage is_ = LibAppStorage.itemsStorage();
        InventoryStorage storage ivs = LibAppStorage.inventoryStorage();
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(ss.sellRate > 0, "LibStore: sell rate not set");
        Item memory item = is_.items[_itemId];
        require(
            ivs.userInventoryItemIds[LibRegistry.playerAccount()].contains(_itemId),
            "LibStore: not item owner"
        );
        require(
            item.position == Position.Inventory,
            "LibStore: not in inventory"
        );
        uint256 totalPrice = (ss.itemTypePrices[item.itemType] * ss.sellRate) /
            100_00;
        cs.balances[LibRegistry.playerAccount()] += totalPrice;
        // Remove item id from owner's inventory
        EnumerableSet.UintSet storage userInventoryItemIds = ivs.userInventoryItemIds[LibRegistry.playerAccount()];
        userInventoryItemIds.remove(_itemId);
        emit ItemsSold(item.itemType, 1, LibRegistry.playerAccount());
    }

    function airdropSeed(
        address _receiver,
        uint256 _seedId,
        uint256 _amount
    ) internal {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        is_.seedQuantities[_receiver][_seedId] += _amount;
    }

    function buyFarmSupply(
        FarmSupplyCategory _farmSupplyId,
        uint256 _amount
    ) internal {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(_amount > 0, "LibStore: _amount must be > 0");
        require(
            ss.farmSupplyPrices[uint32(_farmSupplyId)] > 0,
            "LibStore: farm supply price not set"
        );
        require(
            ss.availableFarmSupplyQuantities[uint32(_farmSupplyId)] >= _amount,
            "LibStore: not enough farm supply available"
        );
        uint256 totalPrice = ss.farmSupplyPrices[uint32(_farmSupplyId)] *
            _amount;
        require(
            cs.balances[LibRegistry.playerAccount()] >= totalPrice,
            "LibStore: not enough funds"
        );
        ss.availableFarmSupplyQuantities[uint32(_farmSupplyId)] -= _amount;
        cs.balances[LibRegistry.playerAccount()] -= totalPrice;
        is_.farmSupplyQuantities[LibRegistry.playerAccount()][
            uint32(_farmSupplyId)
        ] += _amount;
        emit FarmSupplyBought(_farmSupplyId, _amount, LibRegistry.playerAccount());
    }

    function sellFarmSupply(
        FarmSupplyCategory _farmSupplyId,
        uint256 _amount
    ) internal {
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(_amount > 0, "LibStore: _amount must be > 0");
        require(ss.sellRate > 0, "LibStore: sell rate not set");
        require(
            is_.farmSupplyQuantities[LibRegistry.playerAccount()][
                uint32(_farmSupplyId)
            ] >= _amount,
            "LibStore: not enough farm supply owned"
        );
        is_.farmSupplyQuantities[LibRegistry.playerAccount()][
            uint32(_farmSupplyId)
        ] -= _amount;
        uint256 totalPrice = (ss.farmSupplyPrices[uint32(_farmSupplyId)] *
            _amount *
            ss.sellRate) / 100_00;
        cs.balances[LibRegistry.playerAccount()] += totalPrice;
        emit FarmSupplySold(_farmSupplyId, _amount, LibRegistry.playerAccount());
    }

    function sellPlantProduction(uint256 _seedId, uint256 _amount) internal {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        Seed memory seed = LibLand._getSeed(_seedId);
        StoreStorage storage ss = LibAppStorage.storeStorage();
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        require(
            is_.plantProducedQuantities[LibRegistry.playerAccount()][_seedId] >=
                _amount,
            "LibStore: not enough plant production owned"
        );
        is_.plantProducedQuantities[LibRegistry.playerAccount()][
            _seedId
        ] -= _amount;
        uint256 receiveAmount = seed.rewardPerProduct * _amount * ss.sellRate/ 100_00;
        cs.balances[LibRegistry.playerAccount()] += receiveAmount;
    }

    // function sellBreedingProduction(uint256 _animalKindId, uint256 _amount) internal {
    //     LandStorage storage ls = LibAppStorage.landStorage();
    //     InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
    //     StoreStorage storage ss = LibAppStorage.storeStorage();
    //     CurrencyStorage storage cs = LibAppStorage.currencyStorage();
    //     AnimalKind storage animalKind = ls.animalKinds[_animalKindId];
    //     require(
    //         is_.breedingProducedQuantities[LibRegistry.playerAccount()][_animalKindId] >=
    //             _amount,
    //         "LibStore: not enough breeding production owned"
    //     );
    //     is_.breedingProducedQuantities[LibRegistry.playerAccount()][
    //         _animalKindId
    //     ] -= _amount;
    //     uint256 receiveAmount = animalKind.rewardPerProduct * _amount * ss.sellRate / 100_00;
    //     cs.balances[LibRegistry.playerAccount()] += receiveAmount;
    // }

    function airdropFarmSupply(
        address _receiver,
        FarmSupplyCategory _farmSupplyId,
        uint256 _amount
    ) internal {
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        is_.farmSupplyQuantities[_receiver][uint32(_farmSupplyId)] += _amount;
    }
}
