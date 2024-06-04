// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct CraftRequirement {
    uint256 quantity;
    uint256 seedId;
    uint256 animalKindId;
}

struct CraftProduct {
    uint256 id;
    uint256 price;
    uint64 expReward; 
    uint64 duration;
    uint64 totalRequirements;
    uint32 craftType;
}

enum CraftType {
    None,
    Dairy,
    Cake,
    Juice
}


struct CraftingProcess{
  uint64 startTime;
  uint64 finishTime;
  uint256 quantity;
  // uint256 claimedQuantity;
}

struct CraftingStorage {
  CraftProduct[] craftProducts;
  mapping(uint256 => CraftRequirement[256]) craftRequirements;
  mapping(uint256 => mapping(uint256 => CraftingProcess)) buildingIdToCraftingProcesses;
}