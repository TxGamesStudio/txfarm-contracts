// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibBlueprint} from "../libraries/LibBlueprint.sol";
import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import {LandStorage, Seed, AnimalKind} from "../../shared/storage/LandStorage.sol";
import {InventoryStorage} from "../../shared/storage/InventoryStorage.sol";
import {ItemType, Size, ItemCategory, ItemsStorage} from "../../shared/storage/ItemsStorage.sol";
import {FarmSupplyCategory} from "../../shared/storage/InventoryStorage.sol";
import {StoreStorage} from "../../shared/storage/StoreStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";
import {LibLand} from "../libraries/LibLand.sol";
import {Order, Requirement, RequirementList} from "../../shared/storage/OrderStorage.sol";
import {ITxFarmLand} from "../../shared/interfaces/ITxFarmLand.sol";
import {ITxFarmCharacter} from "../../shared/interfaces/ITxFarmCharacter.sol";
import {ConfigStorage} from "../../shared/storage/ConfigStorage.sol";
import {CraftRequirement, CraftProduct, CraftingStorage} from "../../shared/storage/CraftingStorage.sol";

contract BlueprintFacet is Modifiers {
    function setWelcomeItemsConfig(
        uint32 landMap,
        ItemType[] memory welcomeItemTypes,
        uint256[] memory welcomeItemQuantities,
        uint8[] memory welcomeItemInitPositionX,
        uint8[] memory welcomeItemInitPositionY,
        bool[] memory isRotated
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            welcomeItemTypes.length == welcomeItemQuantities.length,
            "BlueprintFacet: welcomeItemTypes and welcomeItemQuantities length mismatch"
        );
        require(
            welcomeItemInitPositionX.length == welcomeItemInitPositionY.length,
            "BlueprintFacet: welcomeItemInitPositionY and welcomeItemInitPositionX length mismatch"
        );
        uint256 totalItems;
        for (uint256 i; i < welcomeItemTypes.length; i++) {
            totalItems += welcomeItemQuantities[i];
        }
        require(
            totalItems == welcomeItemInitPositionX.length,
            "BlueprintFacet: totalItems and welcomeItemInitPositionX length mismatch"
        );
        require(
            totalItems == welcomeItemInitPositionY.length,
            "BlueprintFacet: totalItems and welcomeItemInitPositionY length mismatch"
        );
        ItemsStorage storage is_ = LibAppStorage.itemsStorage();
        is_.welcomeItemTypes[landMap] = welcomeItemTypes;
        is_.welcomeItemQuantities[landMap] = welcomeItemQuantities;
        is_.welcomeItemInitPositionX[landMap] = welcomeItemInitPositionX;
        is_.welcomeItemInitPositionY[landMap] = welcomeItemInitPositionY;
        is_.welcomeItemIsRotated[landMap] = isRotated;
    }

    function setSeeds(
        uint256[] memory _seedIds,
        uint64[] memory _growthDurations,
        uint256[] memory _prices,
        uint64[] memory _produceQuantities,
        uint256[] memory _rewardPerProducts,
        uint64[] memory _expPerProducts,
        uint64[] memory _expHarvestRewards
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LandStorage storage ls = LibAppStorage.landStorage();
        require(
            _seedIds.length == _growthDurations.length,
            "BlueprintFacet: _seedId and _growthDuration length mismatch"
        );
        require(
            _seedIds.length == _prices.length,
            "BlueprintFacet: _seedId and _price length mismatch"
        );
        require(
            _seedIds.length == _produceQuantities.length,
            "BlueprintFacet: _seedId and _productionQuantity length mismatch"
        );
        require(
            _seedIds.length == _rewardPerProducts.length,
            "BlueprintFacet: _seedId and _rewardPerProduct length mismatch"
        );
        require(
            _seedIds.length == _expPerProducts.length,
            "BlueprintFacet: _seedId and _expPerProduct length mismatch"
        );
        delete ls.seeds;
        ls.seeds.push(Seed(0, 0, 0, 0, 0, 0, 0));
        for (uint256 i; i < _seedIds.length; i++) {
            require(
                _seedIds[i] > 0 && _growthDurations[i] > 0,
                "BlueprintFacet: invalid seed or growth duration"
            );
            ls.seeds.push(
                Seed(
                    _seedIds[i],
                    _prices[i],
                    _growthDurations[i],
                    _produceQuantities[i],
                    _rewardPerProducts[i],
                    _expPerProducts[i],
                    _expHarvestRewards[i]
                )
            );
        }
    }

    function setAnimalKinds(
        uint256[] memory _animalKindIds,
        uint64[] memory _growthDurations,
        uint256[] memory _prices,
        uint64[] memory _produceQuantities,
        uint256[] memory _rewardPerProducts,
        uint64[] memory _expPerProducts,
        uint64[] memory _expHarvestRewards
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LandStorage storage ls = LibAppStorage.landStorage();
        require(
            _animalKindIds.length == _growthDurations.length,
            "BlueprintFacet: _animalKindIds and _growthDuration length mismatch"
        );
        require(
            _animalKindIds.length == _prices.length,
            "BlueprintFacet: _animalKindIds and _price length mismatch"
        );
        require(
            _animalKindIds.length == _produceQuantities.length,
            "BlueprintFacet: _animalKindIds and _productionQuantity length mismatch"
        );
        require(
            _animalKindIds.length == _rewardPerProducts.length,
            "BlueprintFacet: _animalKindIds and _rewardPerProduct length mismatch"
        );
        require(
            _animalKindIds.length == _expPerProducts.length,
            "BlueprintFacet: _animalKindIds and _expPerProduct length mismatch"
        );
        require(
            _animalKindIds.length == _expHarvestRewards.length,
            "BlueprintFacet: _animalKindIds and _expHarvestReward length mismatch"
        );
        delete ls.animalKinds;
        ls.animalKinds.push(AnimalKind(0, 0, 0, 0, 0, 0, 0));
        for (uint256 i; i < _animalKindIds.length; i++) {
            require(
                _animalKindIds[i] > 0 && _growthDurations[i] > 0,
                "BlueprintFacet: invalid animal kind or growth duration"
            );
            ls.animalKinds.push(
                AnimalKind(
                    _animalKindIds[i],
                    _prices[i],
                    _growthDurations[i],
                    _produceQuantities[i],
                    _rewardPerProducts[i],
                    _expPerProducts[i],
                    _expHarvestRewards[i]
                )
            );
        }
    }

    function setItemTypeCategory(
        ItemType[] memory _itemType,
        ItemCategory[] memory _categories
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            _itemType.length == _categories.length,
            "BlueprintFacet: _itemType and _categories length mismatch"
        );
        for (uint256 i; i < _itemType.length; i++) {
            LibAppStorage.itemsStorage().itemCategories[
                uint32(_itemType[i])
            ] = _categories[i];
        }
    }

    function setItemTypeSize(
        ItemType[] memory _itemType,
        uint8[] memory _widths,
        uint8[] memory _heights
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            _itemType.length == _widths.length,
            "BlueprintFacet: _itemType and _width length mismatch"
        );
        require(
            _itemType.length == _heights.length,
            "BlueprintFacet: _itemType and _height length mismatch"
        );
        for (uint256 i; i < _itemType.length; i++) {
            require(
                uint256(_itemType[i]) > 1,
                "BlueprintFacet: invalid item type"
            );
            require(
                _widths[i] > 0 && _heights[i] > 0,
                "BlueprintFacet: invalid width or height"
            );
            LibAppStorage.itemsStorage().sizes[uint32(_itemType[i])] = Size(
                _widths[i],
                _heights[i]
            );
        }
    }

    function setItemTypePrices(
        ItemType[] memory _itemType,
        uint256[] memory _prices
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            _itemType.length == _prices.length,
            "BlueprintFacet: _itemType and _prices length mismatch"
        );
        for (uint256 i; i < _itemType.length; i++) {
            require(
                uint256(_itemType[i]) > 1,
                "BlueprintFacet: invalid item type"
            );
            LibAppStorage.storeStorage().itemTypePrices[uint32(_itemType[i])] = _prices[i];
        }
    }

    function setMaxRefreshOrderDaily(
        uint8 _maxRefreshDaily
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.orderStorage().maxRefreshDaily = _maxRefreshDaily;
    }

    function setMaxFulfillOrderDaily(
        uint8 _maxFulfillDaily
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.orderStorage().maxFulfillDaily = _maxFulfillDaily;
    }

    function setOrderRefreshFee(
        uint256 _fee
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.orderStorage().refreshFee = _fee;
    }

    function setOrderDeliveryDuration(
        uint64 _duration
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.orderStorage().deliveryDuration = _duration;
    }

    function increasePlantProducedQuantities(
        address _player,
        uint256[] memory _seedIds,
        uint256[] memory _quantities
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            _seedIds.length == _quantities.length,
            "BlueprintFacet: _seedIds and _quantities length mismatch"
        );
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        for (uint256 i; i < _seedIds.length; i++) {
            is_.plantProducedQuantities[_player][_seedIds[i]] += _quantities[i];
        }
    }

    function increaseBreedingProducedQuantities(
        address _player,
        uint256[] memory _animalKindIds,
        uint256[] memory _quantities
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            _animalKindIds.length == _quantities.length,
            "BlueprintFacet: _animalKindIds and _quantities length mismatch"
        );
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        for (uint256 i; i < _animalKindIds.length; i++) {
            is_.breedingProducedQuantities[_player][_animalKindIds[i]] += _quantities[i];
        }
    }

    function setSeedPrice(
        uint256 _seedId,
        uint256 _price
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LandStorage storage ls = LibAppStorage.landStorage();
        Seed memory seed = LibLand._getSeed(_seedId);
        for (uint256 i; i < ls.seeds.length; i++) {
            if (ls.seeds[i].id == seed.id) {
                ls.seeds[i].price = _price;
                break;
            }
        }
    }

    function setFarmSupplyPrices(
        FarmSupplyCategory[] memory _farmSupplyIds,
        uint256[] memory _prices
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(
            _farmSupplyIds.length == _prices.length,
            "LibBlueprint: _farmSupplyIds and _prices length mismatch"
        );
        for (uint256 i; i < _farmSupplyIds.length; i++) {
            ss.farmSupplyPrices[uint32(_farmSupplyIds[i])] = _prices[i];
        }
    }

    function setStoreSeedAvailableQuantities(
        uint256[] memory _seedIds,
        uint256[] memory _quantities
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(
            _seedIds.length == _quantities.length,
            "LibBlueprint: _seedIds and _quantities length mismatch"
        );
        for (uint256 i; i < _seedIds.length; i++) {
            ss.availableSeedQuantities[_seedIds[i]] = _quantities[i];
        }
    }

    function setStoreItemTypeAvaiableQuantities(
        ItemType[] memory _itemTypes,
        uint256[] memory _quantities
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(
            _itemTypes.length == _quantities.length,
            "LibBlueprint: _itemTypes and _quantities length mismatch"
        );
        for (uint256 i; i < _itemTypes.length; i++) {
            ss.availableItemTypeQuantities[uint32(_itemTypes[i])] = _quantities[i];
        }
    }

    function setStoreFarmSupplyAvailableQuantities(
        FarmSupplyCategory[] memory _farmSupplyIds,
        uint256[] memory _quantities
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(
            _farmSupplyIds.length == _quantities.length,
            "LibBlueprint: _farmSupplyIds and _quantities length mismatch"
        );
        for (uint256 i; i < _farmSupplyIds.length; i++) {
            ss.availableFarmSupplyQuantities[
                uint32(_farmSupplyIds[i])
            ] = _quantities[i];
        }
    }

    function setCowStableSlotUnlockPrice(
        uint256 _price
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.landStorage().cowStableSlotUnlockPrice = _price;
    }

    function setChickenCoopSlotUnlockPrice(
        uint256 _price
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.landStorage().chickenCoopSlotUnlockPrice = _price;
    }

     function setSeedsBuyable(uint256[] memory _seedIds, bool[] memory _isBuyables) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(_seedIds.length == _isBuyables.length, "StoreFacet: _seedIds and _isBuyables length mismatch");
        for (uint256 i; i < _seedIds.length; i++) {
            ss.isSeedBuyables[_seedIds[i]] = _isBuyables[i];
        }
    }

    function setFarmSuppliesBuyable(uint32[] memory _farmSupplyIds, bool[] memory _isBuyables) external  onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(_farmSupplyIds.length == _isBuyables.length, "StoreFacet: _farmSupplyIds and _isBuyables length mismatch");
        for (uint256 i; i < _farmSupplyIds.length; i++) {
            ss.isFarmSupplyBuyables[_farmSupplyIds[i]] = _isBuyables[i];
        }
    }

    function setItemTypesBuyable(uint32[] memory _itemTypeIds, bool[] memory _isBuyables) external  onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        StoreStorage storage ss = LibAppStorage.storeStorage();
        require(_itemTypeIds.length == _isBuyables.length, "StoreFacet: _itemTypeIds and _isBuyables length mismatch");
        for (uint256 i; i < _itemTypeIds.length; i++) {
            ss.isItemTypeBuyables[_itemTypeIds[i]] = _isBuyables[i];
        }
    }

    function setMaxCropHarvestableTimes(
        uint32 _maxCropHarvestableTimes
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.itemsStorage().maxCropHarvestableTimes = _maxCropHarvestableTimes;
    }

    function withdrawEther(address payable _to, uint256 _amount) external onlyRole(LibAccessControl.FINANCIAL_ROLE) {
        _to.transfer(_amount);
    }

    // function setInitLandPrice(uint256 _price) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
    //     LibAppStorage.landStorage().initLandPrice = _price;
    // }

    struct RequirementParams {
        Requirement[] requirements;
    }

    function setTierToRequirementList(
        uint8 _tier,
        RequirementParams[] memory _requirementParams
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        RequirementList[256] storage tierToRequirementList = LibAppStorage.orderStorage().tierToRequirementList[_tier];
        for (uint256 i; i < _requirementParams.length; i++) {
            for (uint256 j; j < _requirementParams[i].requirements.length; j++) {
                tierToRequirementList[i].requirements[j] = _requirementParams[i].requirements[j];
            }
            tierToRequirementList[i].totalRequirements = uint8(_requirementParams[i].requirements.length);
            tierToRequirementList[i].tier = _tier;
        }
        LibAppStorage.orderStorage().tierToTotalRequirementList[_tier] = uint256(_requirementParams.length);
    }

    function setTierToCoefRate(
        uint8[] memory _tier,
        uint256[] memory _coefRate
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            _tier.length == _coefRate.length,
            "BlueprintFacet: _tier and _coefRate length mismatch"
        );
        for (uint256 i; i < _tier.length; i++) {
            LibAppStorage.orderStorage().tierToCoefRate[_tier[i]] = _coefRate[i];
        }
    }

    function setUserProfileSetting(
        uint256 _baseExp,
        uint256 _levelCoefRate,
        uint256[] memory _levelToTierThreshold,
        uint256[] memory _levelToCummulativeExpThreshold
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.userProfileStorage().baseExp = _baseExp;
        LibAppStorage.userProfileStorage().levelCoefRate = _levelCoefRate;
        LibAppStorage.userProfileStorage().levelToTierThreshold = _levelToTierThreshold;
        LibAppStorage.userProfileStorage().levelToCummulativeExpThreshold = _levelToCummulativeExpThreshold;
    }

    function setBaseExp(uint256 _baseExp) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.userProfileStorage().baseExp = _baseExp;
    }

    function setLevelToCummulativeExpThreshold(uint256[] memory _levelToCummulativeExpThreshold) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        LibAppStorage.userProfileStorage().levelToCummulativeExpThreshold = _levelToCummulativeExpThreshold;
    }
    
    function setStoreSellRate(uint256 _sellRate) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(_sellRate <= 100_00 && _sellRate > 0, "BlueprintFacet: invalid sell rate");
        LibAppStorage.storeStorage().sellRate = _sellRate;
    }

    function setTxFarmLandContract(address _TxFarmLandContract) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        cs.TxFarmLandContract = ITxFarmLand(_TxFarmLandContract);
    }

    function getTxFarmLandContract() external view returns (address) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        return address(cs.TxFarmLandContract);
    }

    function setTxFarmCharacterContract(address _TxFarmCharacterContract) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        cs.TxFarmCharacterContract = ITxFarmCharacter(_TxFarmCharacterContract);
    }

    function getTxFarmCharacterContract() external view returns (address) {
        ConfigStorage storage cs = LibAppStorage.configStorage();
        return address(cs.TxFarmCharacterContract);
    }

    function setUserTierToOrderTierRates(
        uint8[] memory tiers,
        uint256[][] memory rates
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(
            tiers.length == rates.length,
            "BlueprintFacet: tiers and rates length mismatch"
        );
        for (uint256 i; i < tiers.length; i++) {
            LibAppStorage.orderStorage().userTierToOrderTierRates[tiers[i]] = rates[i];
        }
    }

    function setCraftProducts(
        uint256[] memory _craftProductIds,
        uint256[] memory _prices,
        uint64[] memory _expRewards,
        uint64[] memory _durations,
        uint32[] memory _craftTypes,
        CraftRequirement[][] memory _requirements
    ) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        CraftingStorage storage cs = LibAppStorage.craftingStorage();
        require(
            _craftProductIds.length == _prices.length,
            "BlueprintFacet: _craftProductIds and _prices length mismatch"
        );
        require(
            _craftProductIds.length == _expRewards.length,
            "BlueprintFacet: _craftProductIds and _expRewards length mismatch"
        );
        require(
            _craftProductIds.length == _durations.length,
            "BlueprintFacet: _craftProductIds and _durations length mismatch"
        );
        require(
            _craftProductIds.length == _requirements.length,
            "BlueprintFacet: _craftProductIds and _requirements length mismatch"
        );
        delete cs.craftProducts;
        cs.craftProducts.push(CraftProduct(0, 0, 0, 0, 0, 0));
        for (uint256 i; i < _craftProductIds.length; i++) {
            cs.craftProducts.push(
                CraftProduct(
                    _craftProductIds[i],
                    _prices[i],
                    _expRewards[i],
                    _durations[i],
                    uint64(_requirements[i].length),
                    _craftTypes[i]
                )
            );
            for (uint256 j; j < _requirements[i].length; j++) {
                cs.craftRequirements[_craftProductIds[i]][j] = _requirements[i][j];
            }
        }
    }

    function setLandMap(uint32 _landType, uint256[] memory _indexs, uint256[] memory _values) external onlyRole(LibAccessControl.BLUEPRINT_ROLE) {
        require(_indexs.length == _values.length, "BlueprintFacet: _indexs and _values length mismatch");
        for (uint256 i; i < _indexs.length; i++) {
            LibAppStorage.landStorage().landMaps[_landType][_indexs[i]] = _values[i];
        }
    }
    
}
