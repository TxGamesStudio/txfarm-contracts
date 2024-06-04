// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LandStorage} from "../../shared/storage/LandStorage.sol";

library LibBlueprint {
    using EnumerableSet for EnumerableSet.UintSet;
}
