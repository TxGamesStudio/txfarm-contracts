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
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "hardhat/console.sol";

contract LandFacet is Modifiers {

    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private constant ID_INACTIVE = 0;
    uint256 private constant ID_ACTIVE = 1;

    modifier onlyLandOwner(uint256 _landId) {
        require(
            LibLand.getLandOwner(_landId) == LibRegistry.playerAccount(),
            "LibLand: not land owner"
        );
        _;
    }

    modifier onlyItemOwner(uint256 _itemId) {
        uint256[] memory owningItemIds = LibItems.getOwningItemIds(
            LibRegistry.playerAccount()
        );
        bool isOwner = false;
        for (uint256 i; i < owningItemIds.length; i++) {
            if (owningItemIds[i] == _itemId) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "LandFacet: not item owner");
        _;
    }

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

    event PlantDestroyed(
        uint256 indexed _landId,
        uint8 indexed _plotPositionX,
        uint8 indexed _plotPositionY,
        uint256 _seedId,
        uint256 _plantId,
        address _farmer,
        uint64 timestamp
    );

    function initLand() external payable whenNotPaused {
        LibLand.initLand();
    }

    // function getInitLandPrice() external view returns (uint256) {
    //     LandStorage storage ls = LibAppStorage.landStorage();
    //     return ls.initLandPrice;
    // }

    function setMapPositions(
        uint256 _landId,
        MapPosition[] memory _currentMapPositions,
        MapPosition[] memory _mapPositions
    ) external onlyLandOwner(_landId) whenNotPaused {
        LibItems.setMapPositions(_landId, _currentMapPositions, _mapPositions);
    }

    function getLandPlots(
        uint256 _landId,
        uint256 _start,
        uint256 _offset
    ) external view returns (address owner, string[] memory _map) {
        LandStorage storage ls = LibAppStorage.landStorage();
        Land storage land = ls.lands[_landId];
        string[] memory map = new string[](100);
        uint256[100][100] memory plots = land.plots;
        for (uint8 i; i < 100; i++) {
            for (uint8 j; j < 100; j++) {
                if (plots[i][j] > 1) {
                    Item storage item = LibAppStorage.itemsStorage().items[
                        plots[i][j]
                    ];
                    Size memory size = LibAppStorage.itemsStorage().sizes[
                        item.itemType
                    ];
                    if (item.isRotated) {
                        size = Size(size.height, size.width);
                    }
                    bool isFill;
                    if (i == 0 && j == 0) {
                        isFill = true;
                    } else if (i == 0 && plots[i][j] != plots[i][j - 1]) {
                        isFill = true;
                    } else if (j == 0 && plots[i][j] != plots[i - 1][j]) {
                        isFill = true;
                    } else if (
                        plots[i][j] != plots[i - 1][j] &&
                        plots[i][j] != plots[i][j - 1]
                    ) {
                        isFill = true;
                    }
                    if (isFill) {
                        console.log("filing id", plots[i][j]);
                        console.log("filling size", size.width, size.height);
                        for (uint8 k; k < size.width; k++) {
                            for (uint8 l; l < size.height; l++) {
                                console.log("filling", i + l, j + k);
                                plots[i + l][j + k] = plots[i][j];
                            }
                        }
                    }
                }
            }
        }
        for (uint8 i; i < 100; i++) {
            uint256 row0Value = plots[i][0];
            if (
                plots[i][0] == ID_INACTIVE && LibLand.isPlotActive(land, i, 0)
            ) {
                row0Value = ID_ACTIVE;
            }
            string memory row = Strings.toString(row0Value);
            for (uint8 j = 1; j < 100; j++) {
                uint256 plotValue = plots[i][j];
                if (
                    plots[i][j] == ID_INACTIVE &&
                    LibLand.isPlotActive(land, i, j)
                ) {
                    plotValue = ID_ACTIVE;
                }
                row = string(
                    abi.encodePacked(row, ",", Strings.toString(plotValue))
                );
            }
            map[i] = row;
        }
        string[] memory returnMap = new string[](_offset);
        for (uint256 i; i < _offset; i++) {
            returnMap[i] = map[_start + i];
        }
        return (LibLand.getLandOwner(_landId), returnMap);
    }

    function getLandItemIds(
        uint256 _landId
    ) external view returns(uint256[] memory) {
        LandStorage storage ls = LibAppStorage.landStorage();
        return ls.lands[_landId].holdingItemIds.values();
    }

    function getLand(
        uint256 _landId,
        uint256 _start,
        uint256 _offset
    ) external view returns (address owner, uint32 landMapId, string[] memory _map) {
        LandStorage storage ls = LibAppStorage.landStorage();
        Land storage land = ls.lands[_landId];
        string[] memory map = new string[](100);
        for (uint8 i; i < 100; i++) {
            uint256 row0Value = land.plots[i][0];
            if (
                land.plots[i][0] == ID_INACTIVE &&
                LibLand.isPlotActive(land, i, 0)
            ) {
                row0Value = ID_ACTIVE;
            }
            string memory row = Strings.toString(row0Value);
            for (uint8 j = 1; j < 100; j++) {
                uint256 plotValue = land.plots[i][j];
                if (
                    land.plots[i][j] == ID_INACTIVE &&
                    LibLand.isPlotActive(land, i, j)
                ) {
                    plotValue = ID_ACTIVE;
                }
                row = string(
                    abi.encodePacked(row, ",", Strings.toString(plotValue))
                );
            }
            map[i] = row;
        }
        string[] memory returnMap = new string[](_offset);
        for (uint256 i; i < _offset; i++) {
            returnMap[i] = map[_start + i];
        }
        return (LibLand.getLandOwner(_landId), land.landMapId, returnMap);
    }

    function getLandsOfOwner(
        address _owner
    ) external view returns (uint256[] memory) {
        return LibLand.getLandsOfOwner(_owner);
    }

    function getSeeds() external view returns (Seed[] memory) {
        LandStorage storage ls = LibAppStorage.landStorage();
        return ls.seeds;
    }

    function getAnimalKinds() external view returns (AnimalKind[] memory) {
        LandStorage storage ls = LibAppStorage.landStorage();
        return ls.animalKinds;
    }

    function seed(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _seedId
    ) external whenNotPaused onlyLandOwner(_landId) {
        LibLand.seed(_landId, _plotPositionX, _plotPositionY, _seedId);
    }

    function water(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external whenNotPaused onlyLandOwner(_landId) {
        LibLand.water(_landId, _plotPositionX, _plotPositionY);
    }

    function fertilize(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external whenNotPaused onlyLandOwner(_landId) {
        LibLand.fertilize(_landId, _plotPositionX, _plotPositionY);
    }

    function harvest(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external whenNotPaused {
        LibLand.harvest(_landId, _plotPositionX, _plotPositionY);
    }

    function destroyPlant(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external whenNotPaused onlyLandOwner(_landId) {
        LibLand.destroyPlant(_landId, _plotPositionX, _plotPositionY);
    }

    function getCowStableSlotUnlockPrice() external view returns (uint256) {
        LandStorage storage ls = LibAppStorage.landStorage();
        return ls.cowStableSlotUnlockPrice;
    }

    function getChickenCoopSlotUnlockPrice() external view returns (uint256) {
        LandStorage storage ls = LibAppStorage.landStorage();
        return ls.chickenCoopSlotUnlockPrice;
    }
}
