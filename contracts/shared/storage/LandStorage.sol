// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

enum PlotStage {
    Locked,
    Unlocked,
    Seeded,
    Watered,
    Fertilized,
    Harvested,
    Dead
}

enum PlantState {
    None,
    Sowed,
    Watered,
    Manured,
    Harvestable,
    Harvested,
    Dead
}

enum AnimalState {
    None,
    Hungry,
    Fed,
    Havestable,
    Harvested,
    Dead
}

struct MapPosition {
    uint256 itemId;
    uint8 x;
    uint8 y;
    bool isRotated;
}

struct Seed {
    uint256 id;
    uint256 price;
    uint64 growthDuration;
    uint64 productionQuantity;
    uint256 rewardPerProduct;
    uint64 expPerProduct;
    uint64 expHarvestReward;
}

struct AnimalKind {
    uint256 id;
    uint256 price;
    uint64 growthDuration;
    uint64 productionQuantity;
    uint256 rewardPerProduct;
    uint64 expPerProduct;
    uint64 expHarvestReward;
}

struct Land {
    uint256 id;
    uint256[100][100] plots;
    mapping(uint256 => uint256) plotStatus;
    // mapping(uint256 => uint256) plotFilled;
    EnumerableSet.UintSet holdingItemIds;
    uint32 landMapId;
}

struct Plant {
    uint256 id;
    PlantState state;
    uint64 duration;
    uint256 seedId;
    uint256 belongsToItemId;
    uint64 sowedAt;
    uint64 wateredAt;
    uint64 manuredAt;
    uint64 fertilizerType;
    // uint64 harvestableAfter;
    uint64 harvestedAt;
    bool isStoled;
}

struct Animal {
    uint256 id;
    AnimalState state;
    uint64 duration;
    uint256 animalKindId;
    uint256 belongsToItemId;
    uint64 fedAt;
    // uint64 harvestableAfter;
    uint64 harvestedAt;
    bool isStoled;
}

struct LandStorage {
    mapping(uint256 => Land) lands;
    Seed[] seeds;
    AnimalKind[] animalKinds;
    Plant[] plants;
    Animal[] animals;
    uint256 cowStableSlotUnlockPrice;
    uint256 chickenCoopSlotUnlockPrice;
    uint32 maxCropHarvestableTimes;
    // uint256 initLandPrice;
    mapping(uint32 => mapping(uint256 => uint256)) landMaps;
}
