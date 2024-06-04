// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "../interfaces/ITxFarmLand.sol";
import "../interfaces/ITxFarmCharacter.sol";
struct ConfigStorage {
  ITxFarmLand TxFarmLandContract;
  ITxFarmCharacter TxFarmCharacterContract;    
}