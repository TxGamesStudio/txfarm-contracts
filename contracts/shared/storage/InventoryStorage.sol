// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

enum FarmSupplyCategory {
  None,
  Water,
  Fertilizer
  // CowFeed,
  // ChickenFeed
}

struct InventoryStorage {
  mapping(address => EnumerableSet.UintSet) userInventoryItemIds;
  ///@dev mapping of owner to seedId to quantity
  mapping(address => mapping(uint256 => uint256)) seedQuantities;
  ///@dev mapping of owner to seedId to produced quantity
  mapping(address => mapping(uint256 => uint256)) plantProducedQuantities;

  mapping(address => mapping(uint256 => uint256)) breedingProducedQuantities;

  mapping(address => mapping(uint32 => uint256)) farmSupplyQuantities;

  // mapping(address => mapping(uint256 => uint256)) craftedProductQuantities;
}