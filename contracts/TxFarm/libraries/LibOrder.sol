// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibEIP2771} from "./LibEIP2771.sol";
import {InventoryStorage} from "../../shared/storage/InventoryStorage.sol";
import {CurrencyStorage} from "../../shared/storage/CurrencyStorage.sol";
import {LandStorage, AnimalKind, Seed} from "../../shared/storage/LandStorage.sol";
import {OrderStorage, Order, Requirement, RequirementList} from "../../shared/storage/OrderStorage.sol";
import {LibRNG} from "../libraries/LibRNG.sol";
import {LibRegistry} from "./LibRegistry.sol";
import {LibUserProfile} from "./LibUserProfile.sol";
import {UserProfileStorage, UserProfile} from "../../shared/storage/UserProfileStorage.sol";
import {LibLand} from "./LibLand.sol";
import "hardhat/console.sol";

library LibOrder {
    uint64 private constant ONE_DAY = 24 * 60 * 60;

    event OrdersRefreshed(address indexed _farmer);
    event OrdersFulfilled(address indexed _farmer, uint256[] _orderIndexes);
    event OrdersClaimed(address indexed _farmer, uint256[] _orderIndexes);

    function _generateOrders(address _to) internal {
        OrderStorage storage os = LibAppStorage.orderStorage();
        LandStorage storage ls = LibAppStorage.landStorage();
        UserProfileStorage storage upS = LibAppStorage.userProfileStorage();
        UserProfile storage userProfile = upS.userProfiles[_to];
        ///@dev Generate 4 orders per time
        Order[256] storage orders = os.userOrders[_to];
        ///TO DO: user tier here
        uint8 userTier = userProfile.tier;
        console.log("userTier", userTier);
        if(os.tierToTotalRequirementList[userTier] == 0) {
            console.log("no requirement list at this tier");
            return;
        }
        os.userTotalOrders[_to] = 4;
        for (uint i; i < 4; i++) {
            if (orders[i].isFulfilled && !orders[i].isClaimed) {
                continue;
            }
            if (orders[i].isClaimed && orders[i].expiredAt > block.timestamp) {
                continue;
            }
            if (orders[i].expiredAt > 0) {
                orders[i].isFulfilled = false;
                orders[i].isClaimed = false;
                orders[i].claimableAt = 0;
            }
            orders[i].expiredAt =
                block.timestamp -
                (block.timestamp % ONE_DAY) +
                1 days;
            
            uint256 randomNumber = LibRNG.pseudoRandom(
                i
            ) % 100_00;
            uint8 orderTier;
            uint256[] memory userTierToOrderTierRates = os.userTierToOrderTierRates[userTier];
            for(uint j; j < userTierToOrderTierRates.length; j++) {
                if(randomNumber <= userTierToOrderTierRates[j]) {
                    orderTier = uint8(j) + 1;
                    break;
                }
            }
            uint256 requirementListIndex = randomNumber % os.tierToTotalRequirementList[orderTier];
            RequirementList storage requirementList = os.tierToRequirementList[orderTier][
                requirementListIndex
            ];
            orders[i].requirementListIndex = requirementListIndex;
            orders[i].tier = requirementList.tier;
            uint256 orderRewardAmount;
            uint256 expRewardAmount;
            for (uint j; j < requirementList.totalRequirements; j++) {
                if (requirementList.requirements[j].seedId != 0) {
                    Seed storage seed = ls.seeds[requirementList.requirements[j].seedId];
                    orderRewardAmount += seed.rewardPerProduct * requirementList.requirements[j].quantity;
                    expRewardAmount += seed.expPerProduct * requirementList.requirements[j].quantity;
                } else if (requirementList.requirements[j].animalKindId != 0) {
                    AnimalKind storage animalKind = ls.animalKinds[requirementList.requirements[j].animalKindId];
                    orderRewardAmount += animalKind.rewardPerProduct * requirementList.requirements[j].quantity;
                    expRewardAmount += animalKind.expPerProduct * requirementList.requirements[j].quantity;
                }
            }
            orders[i].rewardAmount = orderRewardAmount * os.tierToCoefRate[orders[i].tier] / 100_00;
            orders[i].expRewardAmount = expRewardAmount * os.tierToCoefRate[orders[i].tier] / 100_00;
        }
    }

    function refreshOrders() internal {
        OrderStorage storage os = LibAppStorage.orderStorage();
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        require(
            LibLand.getLandsOfOwner(LibRegistry.playerAccount()).length > 0,
            "LibOrder: no land"
        );
        uint64 dayNumber = uint64(block.timestamp / ONE_DAY);
        require(
            os.dayNumberToFulfilledTimes[LibRegistry.playerAccount()][
                dayNumber
            ] < os.maxFulfillDaily,
            "LibOrder: exceed max deliver daily"
        );
        require(os.maxFulfillDaily != 0, "LibOrder: max deliver daily is 0");
        require(os.maxRefreshDaily != 0, "LibOrder: max refresh daily is 0");
        require(
            os.dayNumberToRefreshedTimes[LibRegistry.playerAccount()][
                dayNumber
            ] < os.maxRefreshDaily,
            "LibOrder: exceed max refresh daily"
        );
        ///@dev Free refresh once a day
        if (
            os.dayNumberToRefreshedTimes[LibRegistry.playerAccount()][
                dayNumber
            ] != 0
        ) {
            require(os.refreshFee != 0, "LibOrder: refresh fee is 0");
            require(
                cs.balances[LibRegistry.playerAccount()] >= os.refreshFee,
                "LibOrder: not enough funds"
            );
            cs.balances[LibRegistry.playerAccount()] -= os.refreshFee;
        }
        os.dayNumberToRefreshedTimes[LibRegistry.playerAccount()][dayNumber]++;
        _generateOrders(LibRegistry.playerAccount());
        emit OrdersRefreshed(LibRegistry.playerAccount());
    }

    function fulfillOrders(uint256[] memory _orderIndexes) internal {
        OrderStorage storage os = LibAppStorage.orderStorage();
        InventoryStorage storage is_ = LibAppStorage.inventoryStorage();
        Order[256] storage orders = os.userOrders[LibRegistry.playerAccount()];
        require(os.maxFulfillDaily != 0, "LibOrder: max delivery daily is 0");
        uint64 dayNumber = uint64(block.timestamp / ONE_DAY);
        require(
            os.dayNumberToFulfilledTimes[LibRegistry.playerAccount()][
                dayNumber
            ] +
                _orderIndexes.length <=
                os.maxFulfillDaily,
            "LibOrder: exceed max delivery daily"
        );
        os.dayNumberToFulfilledTimes[LibRegistry.playerAccount()][
            dayNumber
        ] += uint8(_orderIndexes.length);

        for (uint256 i; i < _orderIndexes.length; i++) {
            Order storage order = orders[_orderIndexes[i]];
            require(!order.isFulfilled, "LibOrder: order is fullfilled");
            require(
                order.expiredAt > block.timestamp,
                "LibOrder: order is expired"
            );
            RequirementList storage requirementList = os.tierToRequirementList[order.tier][
                order.requirementListIndex
            ];
            Requirement[256] storage requirements = requirementList.requirements;

            for (uint256 j; j < requirementList.totalRequirements; j++) {
                if (requirements[j].seedId != 0) {
                    require(
                        is_.plantProducedQuantities[
                            LibRegistry.playerAccount()
                        ][requirements[j].seedId] >= requirements[j].quantity,
                        "LibOrder: not enough plant produced quantity"
                    );
                } else if (requirements[j].animalKindId != 0) {
                    require(
                        is_.breedingProducedQuantities[
                            LibRegistry.playerAccount()
                        ][requirements[j].animalKindId] >= requirements[j].quantity,
                        "LibOrder: not enough breeding produced quantity"
                    );
                }
            }
            for (uint256 j; j < requirementList.totalRequirements; j++) {
                if (requirements[j].seedId != 0) {
                    is_.plantProducedQuantities[LibRegistry.playerAccount()][
                        requirements[j].seedId
                    ] -= requirements[j].quantity;
                } else if (requirements[j].animalKindId != 0) {
                    is_.breedingProducedQuantities[LibRegistry.playerAccount()][
                        requirements[j].animalKindId
                    ] -= requirements[j].quantity;
                }
            }
            order.isFulfilled = true;
            order.claimableAt = block.timestamp + os.deliveryDuration;
        }
        emit OrdersFulfilled(LibRegistry.playerAccount(), _orderIndexes);
    }

    function claimOrders(uint256[] memory _orderIndexes) internal {
        OrderStorage storage os = LibAppStorage.orderStorage();
        CurrencyStorage storage cs = LibAppStorage.currencyStorage();
        Order[256] storage orders = os.userOrders[LibRegistry.playerAccount()];
        uint256 totalReward;
        uint256 totalExp;
        for (uint256 i; i < _orderIndexes.length; i++) {
            Order storage order = orders[_orderIndexes[i]];
            require(order.isFulfilled, "LibOrder: order is not fullfilled");
            require(!order.isClaimed, "LibOrder: order is claimed");
            require(
                order.claimableAt <= block.timestamp,
                "LibOrder: order is not claimable"
            );
            order.isClaimed = true;
            totalReward += order.rewardAmount;
            totalExp += order.expRewardAmount;
            os.totalFinishedOrders[LibRegistry.playerAccount()]++;
            os.totalClaimedRewards[LibRegistry.playerAccount()] += order
                .rewardAmount;
            os.lastClaimedAt[LibRegistry.playerAccount()] = block.timestamp;
        }
        cs.balances[LibRegistry.playerAccount()] += totalReward;
        LibUserProfile.increaseExp(LibRegistry.playerAccount(), totalExp);
        emit OrdersClaimed(LibRegistry.playerAccount(), _orderIndexes);
    }
}
