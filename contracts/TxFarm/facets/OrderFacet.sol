// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {Order, Requirement, OrderStorage, RequirementList} from "../../shared/storage/OrderStorage.sol";
import {LandStorage} from "../../shared/storage/LandStorage.sol";
import {LibOrder} from "../libraries/LibOrder.sol";

contract OrderFacet is Modifiers {
    event OrdersRefreshed(address indexed _farmer);
    event OrdersFulfilled(address indexed _farmer, uint256[] _orderIndexes);

    struct OrderResponse {
        uint256 expiredAt;
        uint256 rewardAmount;
        uint256 expRewardAmount;
        Requirement[] requirements;
        uint8 totalRequirements;
        bool isFulfilled;
        bool isClaimed;
        uint256 claimableAt;
        uint8 tier;
    }
    struct UserOrderDetail {
        address user;
        uint256 totalFinishedOrders;
        uint256 totalClaimedRewards;
        uint256 lastClaimedAt;
    }

    function getCurrentDayRefreshTimes(address _address) external view returns (uint8) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        uint64 dayNumber = uint64(block.timestamp / 1 days);
        return os.dayNumberToRefreshedTimes[_address][dayNumber];
    }

    function getMaxRefreshDaily() external view returns (uint8) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        return os.maxRefreshDaily;
    }

    function getMaxFulfillDaily() external view returns (uint8) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        return os.maxFulfillDaily;
    }

    function getRefreshFee() external view returns (uint256) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        return os.refreshFee;
    }

    function refreshOrders() external whenNotPaused {
        LibOrder.refreshOrders();
    }

    function getCurrentDayFulfilledTimes(address _address) external view returns (uint8) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        uint64 dayNumber = uint64(block.timestamp / 1 days);
        return os.dayNumberToFulfilledTimes[_address][dayNumber];
    }

    function fulfillOrders(uint256[] memory _orderIndexes) external whenNotPaused {
        LibOrder.fulfillOrders(_orderIndexes);
    }

    function claimOrders(uint256[] memory _orderIndexes) external whenNotPaused {
        LibOrder.claimOrders(_orderIndexes);
    }

    function getOrderDeliveryDuration() external view returns (uint64) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        return os.deliveryDuration;
    }

    function getOrders(address _address) external view returns (OrderResponse[] memory) {
        OrderStorage storage os = LibAppStorage.orderStorage();
        uint8 totalOrders = os.userTotalOrders[_address];
        OrderResponse[] memory orders = new OrderResponse[](totalOrders);
        for (uint256 i; i < totalOrders; i++) {
            orders[i].expiredAt = os.userOrders[_address][i].expiredAt;
            orders[i].rewardAmount = os.userOrders[_address][i].rewardAmount;
            orders[i].expRewardAmount = os.userOrders[_address][i].expRewardAmount;
            orders[i].isFulfilled = os.userOrders[_address][i].isFulfilled;
            orders[i].isClaimed = os.userOrders[_address][i].isClaimed;
            orders[i].claimableAt = os.userOrders[_address][i].claimableAt;
            orders[i].tier = os.userOrders[_address][i].tier;
            orders[i].totalRequirements = os.tierToRequirementList[orders[i].tier][os.userOrders[_address][i].requirementListIndex].totalRequirements;
            RequirementList storage requirementList = os.tierToRequirementList[orders[i].tier][os.userOrders[_address][i].requirementListIndex];
            orders[i].requirements = new Requirement[](requirementList.totalRequirements);
            for (uint256 j; j < requirementList.totalRequirements; j++) {
                orders[i].requirements[j].seedId = requirementList.requirements[j].seedId;
                orders[i].requirements[j].animalKindId = requirementList.requirements[j].animalKindId;
                orders[i].requirements[j].quantity = requirementList.requirements[j].quantity;
            }
        }
        return orders;
    }
}
