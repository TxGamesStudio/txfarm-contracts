// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LandStorage, Land, Seed, PlantState, Plant} from "../../shared/storage/LandStorage.sol";
import {InventoryStorage} from "../../shared/storage/InventoryStorage.sol";
import {Item, ItemType, ItemsStorage} from "../../shared/storage/ItemsStorage.sol";
import {ConfigStorage} from "../../shared/storage/ConfigStorage.sol";
import {CurrencyStorage} from "../../shared/storage/CurrencyStorage.sol";
import {UserProfileStorage} from "../../shared/storage/UserProfileStorage.sol";
import {OrderStorage} from "../../shared/storage/OrderStorage.sol";
import {LibOrder} from "./LibOrder.sol";
import {LibItems} from "./LibItems.sol";
import {LibCurrency} from "./LibCurrency.sol";
import {LibEIP2771} from "./LibEIP2771.sol";
import {LibRegistry} from "./LibRegistry.sol";
import {Bits} from "./Bits.sol";
import {LibUserProfile} from "./LibUserProfile.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LibLand {
    using Bits for uint;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private constant ID_NO_SEED = 0;
    uint256 private constant ID_DEFAULT_GIFT_SEED = 1;
    event LandInitiated(uint256 indexed _landId, address indexed _farmer);
    event PlotReclaimed(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        address _farmer
    );
    event PlotSeeded(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        uint256 _seedId,
        uint256 _plantId,
        address _farmer,
        uint64 timestamp
    );
    event PlantDestroyed(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        uint256 _seedId,
        uint256 _plantId,
        address _farmer,
        uint64 timestamp
    );
    event PlotWatered(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        uint256 _seedId,
        address _farmer,
        uint64 timestamp
    );
    event PlotFertilized(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        uint256 _seedId,
        address _farmer,
        uint64 timestamp
    );
    event PlotHarvested(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        uint256 _seedId,
        address _farmer,
        uint64 timestamp
    );

    function isPlotActive(
        Land storage _land,
        uint8 _plotPostionX,
        uint8 _plotPositionY
    ) internal view returns (bool) {
        return _land.plotStatus[_plotPostionX].bitSet(255 - _plotPositionY);
    }

    // function isPlotFilled(
    //     Land storage _land,
    //     uint8 _plotPostionX,
    //     uint8 _plotPositionY
    // ) internal view returns (bool) {
    //     return _land.plotFilled[_plotPostionX].bitSet(255 - _plotPositionY);
    // }

    function getTotalLand() internal view returns (uint256) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        require(address(cs.TxFarmLandContract) != address(0), "LibLand: land contract not set");
        return cs.TxFarmLandContract.totalSupply();
    }

    function getLandOwner(uint256 _landId) internal view returns (address) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        require(address(cs.TxFarmLandContract) != address(0), "LibLand: land contract not set");
        return cs.TxFarmLandContract.ownerOf(_landId);
    }

    function getLandsOfOwner(address _owner) internal view returns (uint256[] memory) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        require(address(cs.TxFarmLandContract) != address(0), "LibLand: land contract not set");
        uint256 totalLand = cs.TxFarmLandContract.balanceOf(_owner);
        uint256[] memory landIds = new uint256[](totalLand);
        for (uint256 i = 0; i < totalLand; i++) {
            landIds[i] = cs.TxFarmLandContract.tokenOfOwnerByIndex(_owner, i);
        }
        return landIds;
    }

    function initLand() internal {
        LandStorage storage ls = LibAppStorage.landStorage();
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        ConfigStorage storage cs = LibAppStorage.configStorage();
        UserProfileStorage storage ups = LibAppStorage.userProfileStorage();
        CurrencyStorage storage currencyStorage = LibAppStorage.currencyStorage();
        
        // require(ls.initLandPrice > 0, "LibLand: init land price not set");
        // require(msg.value >= ls.initLandPrice, "LibLand: insufficient funds");
        require(
            ups.isInitialized[LibRegistry.playerAccount()] == false,
            "LibLand: user already initiated"
        );
        ups.isInitialized[LibRegistry.playerAccount()] = true;
        ups.totalUsers++;
        uint256 newLandId = LibLand.getTotalLand() + 1;
        cs.TxFarmLandContract.mint(LibRegistry.playerAccount(), newLandId, true);
        uint256 newCharId = cs.TxFarmCharacterContract.totalSupply() + 1;
        cs.TxFarmCharacterContract.mint(LibRegistry.playerAccount(), newCharId, true);
        Land storage newLand = ls.lands[newLandId];
        newLand.id = newLandId;
        //Random landmap from 0 to 2
        newLand.landMapId = uint32(newLandId) % 3;
        is_.seedQuantities[LibRegistry.playerAccount()][ID_DEFAULT_GIFT_SEED] += 3;
        for (uint256 i = 0; i < 100; i++) {
            newLand.plotStatus[
                i
            ] = ls.landMaps[newLand.landMapId][i];
        }
        LibUserProfile.initUserProfile(LibRegistry.playerAccount());
        // LibOrder._generateOrders(LibRegistry.playerAccount());
        LibItems.dropWelcomeItems(LibRegistry.playerAccount(), newLandId, newLand.landMapId);
        currencyStorage.balances[LibRegistry.playerAccount()] = 10 * 10 **18;
        // uint64 dayNumber = uint64(block.timestamp / 1 days);
        // os.dayNumberToRefreshedTimes[LibRegistry.playerAccount()][
        //     dayNumber
        // ] = 1;
        emit LandInitiated(newLandId, LibRegistry.playerAccount());
    }

    function _getSeed(uint256 _seedId) internal view returns (Seed memory) {
        require(_seedId != 0, "LibLand: seed does not exist");
        LandStorage storage ls = LibAppStorage.landStorage();
        return ls.seeds[_seedId];
    }

    function seed(
        uint256 _landId,
        uint8 _plotPostionX,
        uint8 _plotPositionY,
        uint256 _seedId
    ) internal {
        LandStorage storage ls = LibAppStorage.landStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[
            land.plots[_plotPostionX][_plotPositionY]
        ];
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        Seed memory currentSeed = _getSeed(_seedId);
        if (LibAppStorage.itemsStorage().maxCropHarvestableTimes > 0) {
            require(
                LibAppStorage.itemsStorage().harvestedTimes[item.id] <
                    LibAppStorage.itemsStorage().maxCropHarvestableTimes,
                "LibLand: plot already harvested max times"
            );
        }
        require(
            is_.seedQuantities[LibRegistry.playerAccount()][_seedId] > 0,
            "LibLand: not enough seeds"
        );
        require(item.itemType == uint32(ItemType.Crop), "LibLand: not a crop");
        require(
            isPlotActive(land, _plotPostionX, _plotPositionY),
            "LibLand: plot not active"
        );
        require(item.plantIds.length == 0, "LibLand: plot already seeded");
        uint256 newPlantId = ls.plants.length;
        Plant memory newPlant = Plant(
            newPlantId,
            PlantState.Sowed,
            currentSeed.growthDuration,
            currentSeed.id,
            item.id,
            uint64(block.timestamp),
            0,
            0,
            0,
            0,
            false
        );
        ls.plants.push(newPlant);
        item.plantIds.push(newPlantId);
        is_.seedQuantities[LibRegistry.playerAccount()][_seedId]--;
        emit PlotSeeded(
            _landId,
            _plotPostionX,
            _plotPositionY,
            _seedId,
            newPlantId,
            LibRegistry.playerAccount(),
            uint64(block.timestamp)
        );
    }

    function water(
        uint256 _landId,
        uint8 _plotPostionX,
        uint8 _plotPositionY
    ) internal {
        LandStorage storage ls = LibAppStorage.landStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[
            land.plots[_plotPostionX][_plotPositionY]
        ];
        require(item.itemType == uint32(ItemType.Crop), "LibLand: not a crop");
        require(item.plantIds.length > 0, "LibLand: plot not seeded");
        Plant storage plant = ls.plants[item.plantIds[0]];
        require(plant.state == PlantState.Sowed, "LibLand: plot not seeded");
        plant.wateredAt = uint64(block.timestamp);
        plant.state = PlantState.Watered;
        emit PlotWatered(
            _landId,
            _plotPostionX,
            _plotPositionY,
            plant.seedId,
            LibRegistry.playerAccount(),
            uint64(block.timestamp)
        );
    }

    function destroyPlant(
        uint256 _landId,
        uint8 _plotPostionX,
        uint8 _plotPositionY
    ) internal {
        LandStorage storage ls = LibAppStorage.landStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[
            land.plots[_plotPostionX][_plotPositionY]
        ];
        require(item.itemType == uint32(ItemType.Crop), "LibLand: not a crop");
        require(item.plantIds.length > 0, "LibLand: plot not seeded");
        uint256 plantId = item.plantIds[0];
        uint256 seedId = ls.plants[plantId].seedId;
        delete item.plantIds;
        emit PlantDestroyed(
            _landId,
            _plotPostionX,
            _plotPositionY,
            seedId,
            plantId,
            LibRegistry.playerAccount(),
            uint64(block.timestamp)
        );
    }

    function fertilize(
        uint256 _landId,
        uint8 _plotPostionX,
        uint8 _plotPositionY
    ) internal {
        LandStorage storage ls = LibAppStorage.landStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[
            land.plots[_plotPostionX][_plotPositionY]
        ];
        require(item.itemType == uint32(ItemType.Crop), "LibLand: not a crop");
        require(item.plantIds.length > 0, "LibLand: plot not seeded");
        Plant storage plant = ls.plants[item.plantIds[0]];
        require(
            plant.state != PlantState.Manured,
            "LibLand: plot already manured"
        );
        require(plant.state == PlantState.Watered, "LibLand: plot not watered");
        require(
            uint64(block.timestamp) < plant.wateredAt + plant.duration,
            "LibLand: plant already harvestable"
        );
        plant.manuredAt = uint64(block.timestamp);
        plant.state = PlantState.Manured;
        plant.fertilizerType = 1; /// DEFAULT FERTILIZER
        emit PlotFertilized(
            _landId,
            _plotPostionX,
            _plotPositionY,
            plant.seedId,
            LibRegistry.playerAccount(),
            uint64(block.timestamp)
        );
    }

    function harvest(
        uint256 _landId,
        uint8 _plotPostionX,
        uint8 _plotPositionY
    ) internal {
        LandStorage storage ls = LibAppStorage.landStorage();
        InventoryStorage storage ivs = LibAppStorage.inventoryStorage();
        ItemsStorage storage is_ = LibAppStorage.itemsStorage();
        Land storage land = LibAppStorage.landStorage().lands[_landId];
        Item storage item = LibAppStorage.itemsStorage().items[
            land.plots[_plotPostionX][_plotPositionY]
        ];
        require(item.itemType == uint32(ItemType.Crop), "LibLand: not a crop");
        require(item.plantIds.length > 0, "LibLand: plot not seeded");
        Plant storage plant = ls.plants[item.plantIds[0]];
        require(
            plant.state == PlantState.Watered ||
                plant.state == PlantState.Manured,
            "LibLand: plot not watered or fertilized"
        );
        if (plant.state == PlantState.Watered) {
            require(
                uint64(block.timestamp) >= plant.wateredAt + plant.duration,
                "LibLand: plant not ready to harvest"
            );
        } else {
            require(
                uint64(block.timestamp) >= plant.wateredAt + plant.duration / 2,
                "LibLand: plant not ready to harvest"
            );
        }
        Seed memory _seed = _getSeed(plant.seedId);

        ivs.plantProducedQuantities[LibRegistry.playerAccount()][
            plant.seedId
        ] += _seed.productionQuantity;
        LibUserProfile.increaseExp(
            LibRegistry.playerAccount(),
            _seed.expHarvestReward
        );
        plant.state = PlantState.Harvested;
        is_.harvestedTimes[item.id]++;
        delete item.plantIds;

        emit PlotHarvested(
            _landId,
            _plotPostionX,
            _plotPositionY,
            plant.seedId,
            LibRegistry.playerAccount(),
            uint64(block.timestamp)
        );
    }
}
