// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

enum ItemType {
    None,
    Unlocked,
    Crop,
    CowStable,
    FenceFront,
    FenceBack,
    HenHouse,
    Hoe,
    House,
    OrderBoard,
    Rocks,
    Tree,
    Trench,
    Truck,
    WateringBottle,
    Fountaint,
    Market,
    TreeStump,
    WoodPile,
    Strawpile,
    Wood_0,
    Wood_1,
    WareHouse,
    DairyFactory,
    CakeFactory,
    JuiceFactory
}

enum ItemCategory {
    None,
    Decorate,
    Building,
    Farmland,
    Trees,
    Animals,
    Items
}

enum Position {
  Inventory,
  OnLand,
  House
}

struct Size {
  uint8 width;
  uint8 height;
}

struct Item {
  uint256 id;
  uint32 itemType;
  uint256[] animalIds;
  uint256[] plantIds;
  Position position;
  bool isRotated;
  uint256 belongsToLandId;
}

struct ItemsStorage {
  Item[] items;
  //Mapping item type to size
  mapping(uint32 => Size) sizes;
  mapping(uint32 => ItemCategory) itemCategories;

  mapping(uint32 => ItemType[]) welcomeItemTypes;
  
  // Welcome items by land map
  mapping(uint32 => uint256[]) welcomeItemQuantities;
  mapping(uint32 => uint8[]) welcomeItemInitPositionX;
  mapping(uint32 => uint8[]) welcomeItemInitPositionY;
  mapping(uint32 => bool[]) welcomeItemIsRotated;

  // item harvested times
  uint32 maxCropHarvestableTimes;
  mapping(uint256 => uint32) harvestedTimes;

}
