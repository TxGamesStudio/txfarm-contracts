// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {Seed} from "./LandStorage.sol";

struct Requirement {
    uint256 quantity;
    uint256 seedId;
    uint256 animalKindId;
}

struct RequirementList {
    Requirement[256] requirements;
    uint8 totalRequirements;
    uint8 tier;
}

struct Order {
    uint256 expiredAt;
    uint256 rewardAmount;
    uint256 expRewardAmount;
    uint256 requirementListIndex;
    uint8 tier;
    bool isFulfilled;
    bool isClaimed;
    uint256 claimableAt;
}

struct OrderStorage {
    mapping(address => Order[256]) userOrders;
    mapping(address => mapping(uint64 => uint8)) dayNumberToRefreshedTimes;
    mapping(address => uint8) userTotalOrders;
    uint8 maxRefreshDaily;
    uint256 refreshFee;
    uint64 deliveryDuration;
    uint8 maxFulfillDaily;
    mapping(address => mapping(uint64 => uint8)) dayNumberToFulfilledTimes;
    mapping(address => uint256) totalFinishedOrders;
    mapping(address => uint256) totalClaimedRewards;
    mapping(address => uint256) lastClaimedAt;
    mapping(uint8 => RequirementList[256]) tierToRequirementList;
    mapping(uint8 => uint256) tierToTotalRequirementList;
    mapping(uint8 => uint256) tierToCoefRate;
    mapping(uint8 => uint256[]) userTierToOrderTierRates;
}
