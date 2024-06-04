pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {LandStorage, Land, Seed, Animal, Plant} from "../../contracts/shared/storage/LandStorage.sol";
import {ItemType, Item} from "../../contracts/shared/storage/ItemsStorage.sol";
import {Requirement} from "../../contracts/shared/storage/OrderStorage.sol";
import {Order} from "../../contracts/shared/storage/OrderStorage.sol";
import {Forwarder} from "../../contracts/TxFarm/forwarder/Forwarder.sol";
import {IForwarder} from "../../contracts/TxFarm/forwarder/IForwarder.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {TxFarmLand} from "../../contracts/TxFarm/nfts/TxFarmLand.sol";
import {ItemType} from "../../contracts/shared/storage/ItemsStorage.sol";
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

struct ItemResponse {
    uint256 id;
    address owner;
    ItemType itemType;
    Animal[] animals;
    Plant[] plants;
}

struct PlantProducedInventoryItem {
    uint256 seedId;
    uint256 quantity;
}

struct AnimalProducedInventoryItem {
    uint256 animalKindId;
    uint256 quantity;
}

struct MapPosition {
    uint256 itemId;
    uint8 x;
    uint8 y;
    bool isRotated;
}

struct UserProfile {
    uint256 exp;
    uint32 level;
    uint8 tier;
    string username;
}

interface ILand {
    function setSeeds(
        uint256[] memory _seedIds,
        uint64[] memory _growthDurations,
        uint256[] memory _prices
    ) external;

    function getUserProfile(
        address _user
    ) external view returns (UserProfile memory userProfile_);

    function setTrustedForwarder(
        address _trustedForwarder,
        bool _isTrusted
    ) external;

    function initLand() external payable;

    function getLandsOfOwner(
        address _owner
    ) external view returns (uint256[] memory);

    function getLandPlots(
        uint256 _landId,
        uint256 _start,
        uint256 _offset
    ) external view returns (address owner, string[] memory _map);

     function getLand(
        uint256 _landId,
        uint256 _start,
        uint256 _offset
    ) external view returns (address owner, uint32 landMapId, string[] memory _map);

    function seed(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _seedId
    ) external;

    function water(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external;

    function fertilize(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external;

    function harvest(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external;

    function buySeed(uint256 _seedId, uint256 _amount) external;

    function setSeedAvailableQuantity(
        uint256 _seedId,
        uint256 _quantity
    ) external;

    function airdropCurrency(address _receiver, uint256 _amount) external;

    function getCurrencyBalance(
        address _address
    ) external view returns (uint256);

    function getOrders(
        address _address
    ) external view returns (OrderResponse[] memory);

    function fulfillOrders(uint256[] memory _orderIndexes) external;

    function refreshOrders() external;

    function setMaxRefreshOrderDaily(uint8 _maxRefreshDaily) external;

    function setOrderRefreshFee(uint256 _fee) external;

    function getCurrentDayRefreshTimes(
        address _address
    ) external view returns (uint8);

    function getMaxRefreshDaily() external view returns (uint8);

    function getRefreshFee() external view returns (uint256);

    function getReclaimPlotPrice() external view returns (uint256);

    function reclaim(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY
    ) external;

    function setReclaimPlotPrice(uint256 _price) external;

    function pause() external;

    function unpause() external;

    function getOperatorAccountRegistrationMessageToSign(
        address player,
        address operator,
        uint256 expiration,
        uint256 blockNumber
    ) external pure returns (bytes memory);

    function getItemsOfOwner(
        address _owner
    ) external view returns (uint256[] memory);

    function getItems(
        uint256[] calldata itemIds
    ) external view returns (Item[] memory);

    function placeItem(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _itemId
    ) external;

    function getPlantProducedInventoryItems(
        address _owner
    ) external view returns (PlantProducedInventoryItem[] memory);

    function unplaceItem(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _itemId
    ) external;

    function moveItem(
        uint256 _landId,
        uint8 _plotPositionX,
        uint8 _plotPositionY,
        uint256 _itemId,
        uint8 _newPlotPositionX,
        uint8 _newPlotPositionY
    ) external;

    function setMapPositions(
        uint256 _landId,
        MapPosition[] memory _currentMapPositions,
        MapPosition[] memory _mapPositions
    ) external;

    function increasePlantProducedQuantities(
        address _player,
        uint256[] memory _seedIds,
        uint256[] memory _quantities
    ) external;

    function increaseBreedingProducedQuantities(
        address _player,
        uint256[] memory _animalKindIds,
        uint256[] memory _quantities
    ) external;

    function claimOrders(uint256[] memory _orderIndexes) external;

    function unlockCowStableSlot(uint256 _itemId) external;

    function feedCow(uint256 _itemId, uint256 _cowIndex) external;

    function harvestCow(uint256 _itemId, uint256 _cowIndex) external;

    function unlockChickenCoopSlot(uint256 _itemId) external;

    function feedChicken(uint256 _itemId, uint256 _chickenIndex) external;

    function harvestChicken(uint256 _itemId, uint256 _chickenIndex) external;

    function getBreedingProducedInventoryItems(
        address _owner
    ) external view returns (AnimalProducedInventoryItem[] memory);

    function buyItem(ItemType _itemTypeId, uint256 _amount) external;

    function increaseExp(address _user, uint256 _amount) external;

    function setTxFarmLandContract(address _TxFarmLandContract) external;

    function craft(
        uint256 _landId,
        uint256 _buildingId,
        uint256 _craftProductId,
        uint256 _quantity
    ) external;

    function claimCraftedProducts(
        uint256 _landId,
        uint256 _buildingId,
        uint256 _craftProductId
    ) external;
}

contract LandTest is Test {
    string LOCAL_RPC_URL = "http://127.0.0.1:8545";
    uint256 localFork;
    address diamond = 0x0685D7616A6f4C0B6250C792De90FA034Bd33515;
    ILand diamondContract = ILand(diamond);
    Forwarder forwarder;
    TxFarmLand TxFarmLandContract;
    uint256 nonce;

    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 internal constant SIGNER_ROLE = keccak256("SIGNER_ROLE"); // e2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70
    bytes32 internal constant OP_ROLE = keccak256("OP_ROLE");

    address constant OWNER = 0x6eF9503369D11512d73A218B1da7994AA3AdE384;
    address constant BLUEPRINT = 0xEA8c8dFA9Ba0a2b654efa4668E53299F009A8C3b;
    address constant MINTER = 0x185e6BDC7a689c74d8c57a9CFfDE446d8611Ca49;
    address constant OP = 0x93868c6F5a4c1BB70b5549bB0b6C964e034678E3;
    address constant FINANCIAL = 0xd1b93ad0f166B3909Bc96b775181f24d8Ac57028;
    uint256 signerPrivateKey = 0xa11ce;
    address SIGNER = vm.addr(signerPrivateKey);

    address constant HACKER = address(2);

    uint256 truePlayerPrivateKey = 0x123456;
    address TRUE_PLAYER = vm.addr(truePlayerPrivateKey);
    uint256 playerPrivateKey = 0xAcE;
    address PLAYER = vm.addr(playerPrivateKey);

    address constant RELAYER = address(0xabc);

    function setUp() public {
        vm.createSelectFork(LOCAL_RPC_URL);
        TxFarmLandContract = new TxFarmLand();
        TxFarmLandContract.grantRole(MINTER_ROLE, diamond);
        vm.startPrank(BLUEPRINT);
        diamondContract.setTxFarmLandContract(address(TxFarmLandContract));
        // forwarder = new Forwarder();
        // forwarder.registerDomainSeparator("TxFarm", "1.0");
        // diamondContract.setMaxRefreshOrderDaily(4);
        // diamondContract.setOrderRefreshFee(1 ether);
        // diamondContract.setTrustedForwarder(address(forwarder), true);
        vm.stopPrank();
        vm.prank(OP);
        diamondContract.airdropCurrency(TRUE_PLAYER, 100000000000 ether);
        vm.deal(TRUE_PLAYER, 1000 ether);
        // _registerOperator();
        console.log("True Player address: ", TRUE_PLAYER);
    }

    function test_Land() public {
        vm.startPrank(TRUE_PLAYER);
        uint256 gasBefore = gasleft();
        diamondContract.initLand{value: 1 ether}();
        uint256 gasAfter = gasleft();
        console.log("Gas used: ", gasBefore - gasAfter);
        uint256[] memory lands = diamondContract.getLandsOfOwner(TRUE_PLAYER);
        // assertEq(lands.length, 1);
        uint256[] memory items = diamondContract.getItemsOfOwner(TRUE_PLAYER);
        // assertEq(items.length, 23);
        // diamondContract.placeItem(lands[0], 39, 41, items[4].id);
        // diamondContract.moveItem(lands[0], 39, 41, items[4].id, 40, 54);
        // diamondContract.placeItem(lands[0], 39, 41, items[1].id);
        // diamondContract.unplaceItem(lands[0], 39, 42, items[0].id);
        // diamondContract.placeItem(lands[0], 39, 43, items[1].id);
        //         MapPosition[] memory currentMapPositions = new MapPosition[](1);
        //         currentMapPositions[0] = MapPosition(8, 44, 43, false);
        //         // currentMapPositions[1] = MapPosition(items[1], 47, 47);
        // //   filing id 8
        // //   filling size 2 1
        // //   filling 44 43
        // //   filling 44 44
        //         MapPosition[] memory mapPositions = new MapPosition[](1);
        //         mapPositions[0] = MapPosition(8, 44, 43, true);
        //         // mapPositions[1] = MapPosition(items[0], 40, 47);
        //         // //Get gas before
        //         diamondContract.setMapPositions(
        //             lands[0],
        //             currentMapPositions,
        //             mapPositions
        //         );
        //Get gas after

        (address owner, uint32 landMapId, string[] memory _map) = diamondContract.getLand(
            lands[0],
            0,
            100
        );
        for(uint256 i = 0; i < _map.length; i++) {
            console.log(_map[i]);
        }
        // diamondContract.seed(lands[0], 39, 41, 1);
        // Item[] memory itemsAfter = diamondContract.getItemsOfOwner(TRUE_PLAYER);
        // assertEq(itemsAfter[0].plantIds.length, 1);
        // diamondContract.water(lands[0], 39, 41);
        // diamondContract.fertilize(lands[0], 39, 41);
        // skip(15 minutes);
        // diamondContract.harvest(lands[0], 39, 41);
        // uint256[] memory itemIds = new uint256[](1);
        // itemIds[0] = items[0].id;
        // Item[] memory itemsAfterHarvest = diamondContract.getItems(itemIds);
        // assertEq(itemsAfterHarvest[0].plantIds.length, 0);
        // ProducedInventoryItem[] memory producedItems = diamondContract.getProducedInventoryItems(TRUE_PLAYER);
        // assertEq(producedItems[1].quantity, 20);
        // console.log("Cow stable id: ", items[4].id);
        // diamondContract.placeItem(lands[0], 39, 42, items[4].id);
        // diamondContract.moveItem(lands[0], 39, 42, items[4].id, 39, 54);
        // (, string[] memory mapAfterPlaceCowStable) = diamondContract.getLand(lands[0], 0, 100);
        // console.log("Map after place cow stable: ");
        // for (uint256 i = 0; i < mapAfterPlaceCowStable.length; i++) {
        //     console.log(mapAfterPlaceCowStable[i]);
        // // }
        // for (uint256 i = 0; i < map.length; i++) {
        //     // console.log(map[i]);
        // }
        // assertEq(TxFarmLandContract.balanceOf(TRUE_PLAYER), 1);
        // assertEq(TxFarmLandContract.ownerOf(1), TRUE_PLAYER);

        vm.stopPrank();
    }

    function _getRevertMsg(
        bytes memory _returnData
    ) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function _registerOperator() internal {
        bytes memory message = diamondContract
            .getOperatorAccountRegistrationMessageToSign(
                TRUE_PLAYER,
                PLAYER,
                block.timestamp + 10 days,
                block.number
            );
        bytes32 digest = ECDSA.toEthSignedMessageHash(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(truePlayerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        // diamondContract.registerOperator(TRUE_PLAYER, PLAYER, block.timestamp + 10 days, block.number, signature);
        bytes memory registerOperatorData = abi.encodeWithSignature(
            "registerOperator(bytes,address,address,uint256,uint256)",
            signature,
            TRUE_PLAYER,
            PLAYER,
            block.timestamp + 10 days,
            block.number
        );
        _forwardRelayTx(registerOperatorData, playerPrivateKey);
    }

    function test_Forwarder() external {
        vm.startPrank(RELAYER);
        bytes memory initLandData = abi.encodeWithSignature("initLand()");
        _forwardRelayTx(initLandData, playerPrivateKey);
        vm.stopPrank();
    }

    function _forwardRelayTx(
        bytes memory _data,
        uint256 _privateKey
    ) internal returns (bool success, bytes memory ret) {
        IForwarder.ForwardRequest memory req = IForwarder.ForwardRequest(
            vm.addr(_privateKey),
            address(diamondContract),
            0,
            10_000_000,
            nonce++,
            _data,
            block.timestamp + 1 days
        );
        string
            memory GENERIC_PARAMS = "address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data,uint256 validUntilTime";
        string memory requestType = string(
            abi.encodePacked("ForwardRequest(", GENERIC_PARAMS, ")")
        );
        bytes32 requestTypeHash = keccak256(bytes(requestType));
        console.logBytes32(requestTypeHash);
        string
            memory EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
        bytes memory domainValue = abi.encode(
            keccak256(bytes(EIP712_DOMAIN_TYPE)),
            keccak256(bytes("TxFarm")),
            keccak256(bytes("1.0")),
            block.chainid,
            address(forwarder)
        );
        bytes32 domainHash = keccak256(domainValue);
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainHash,
                keccak256(forwarder._getEncoded(req, requestTypeHash, ""))
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_privateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        return
            forwarder.execute(req, domainHash, requestTypeHash, "", signature);
    }

    function test_Craft() public {
        vm.startPrank(TRUE_PLAYER);
        console.log("prank", TRUE_PLAYER);
        diamondContract.initLand{value: 1 ether}();
        vm.stopPrank();
        vm.prank(OP);
        diamondContract.airdropCurrency(TRUE_PLAYER, 1000000000000 ether);
        vm.startPrank(TRUE_PLAYER);
        uint256[] memory lands = diamondContract.getLandsOfOwner(TRUE_PLAYER);
        console.log("Land id: ", lands[0]);
        uint256 balance = diamondContract.getCurrencyBalance(TRUE_PLAYER);
        diamondContract.buyItem(ItemType.DairyFactory, 1);
        uint256[] memory items = diamondContract.getItemsOfOwner(TRUE_PLAYER);
        uint256 dairyCraftId = items[items.length - 1];
        console.log("Dairy craft id: ", dairyCraftId);
        MapPosition[] memory currentMapPositions = new MapPosition[](0);
        MapPosition[] memory mapPositions = new MapPosition[](1);
        mapPositions[0] = MapPosition(dairyCraftId, 45, 45, true);
        diamondContract.setMapPositions(
            lands[0],
            currentMapPositions,
            mapPositions
        );

        vm.stopPrank();

        vm.startPrank(BLUEPRINT);
        uint256[] memory animalKindIds = new uint256[](2);
        uint256[] memory quantities = new uint256[](2);
        animalKindIds[0] = 1;
        animalKindIds[1] = 2;
        quantities[0] = 10;
        quantities[1] = 10;
        diamondContract.increaseBreedingProducedQuantities(
            TRUE_PLAYER,
            animalKindIds,
            quantities
        );
        vm.stopPrank();

        vm.startPrank(TRUE_PLAYER);
        diamondContract.craft(lands[0], dairyCraftId, 1, 1);
        skip(350 * 3);
        uint256 expBeforeClaim = diamondContract
            .getUserProfile(TRUE_PLAYER)
            .exp;
        diamondContract.claimCraftedProducts(lands[0], dairyCraftId, 1);
        uint256 expAfterClaim = diamondContract.getUserProfile(TRUE_PLAYER).exp;
        console.log("Exp before claim: ", expBeforeClaim);
        console.log("Exp after claim: ", expAfterClaim);
        vm.stopPrank();
    }

    function test_FulfillOrder() public {
        vm.startPrank(TRUE_PLAYER);
        diamondContract.initLand{value: 1 ether}();
        vm.stopPrank();
        // vm.startPrank(BLUEPRINT);
        // diamondContract.increaseExp(TRUE_PLAYER, 7000);
        // vm.stopPrank();
        console.log("Land initialized");
        vm.startPrank(TRUE_PLAYER);
        skip(4 minutes);
        diamondContract.refreshOrders();
        UserProfile memory userProfile = diamondContract.getUserProfile(
            TRUE_PLAYER
        );
        console.log("User profile: ", userProfile.exp, userProfile.level);
        OrderResponse[] memory orders = diamondContract.getOrders(TRUE_PLAYER);
        console.log("orders length: ", orders.length);
        console.log("Order 0: ", orders[0].requirements.length, "requirements");
        console.log("Order 0 expired at", orders[0].expiredAt);
        console.log("Order 0 reward amount", orders[0].rewardAmount);
        console.log("Order 0 exp reward amount", orders[0].expRewardAmount);
        // for (uint256 i = 0; i < orders[0].requirements.length; i++) {
        //     console.log(
        //         "Order 0 requirement seedId at",
        //         i,
        //         ": ",
        //         orders[0].requirements[i].seedId
        //     );
        //     console.log(
        //         "Order 0 requirement animalId at",
        //         i,
        //         ": ",
        //         orders[0].requirements[i].animalKindId
        //     );
        //     console.log(
        //         "Order 0 requirement quantity at",
        //         i,
        //         ": ",
        //         orders[0].requirements[i].quantity
        //     );
        // }

        for (uint256 i = 0; i < orders.length; i++) {
            console.log("Order ", i, " is : ", orders[i].requirements.length);
        }

        vm.stopPrank();

        // vm.startPrank(BLUEPRINT);
        // console.log("Start working to fulfill order 0");
        // uint256[] memory seedIds = new uint256[](orders[0].requirements.length);
        // uint256[] memory animalKindIds = new uint256[](
        //     orders[0].requirements.length
        // );
        // uint256[] memory quantities = new uint256[](
        //     orders[0].requirements.length
        // );
        // for (uint256 i = 0; i < orders[0].requirements.length; i++) {
        //     seedIds[i] = orders[0].requirements[i].seedId;
        //     quantities[i] = orders[0].requirements[i].quantity;
        // }
        // for (uint256 i = 0; i < orders[0].requirements.length; i++) {
        //     animalKindIds[i] = orders[0].requirements[i].animalKindId;
        // }
        // diamondContract.increasePlantProducedQuantities(
        //     TRUE_PLAYER,
        //     seedIds,
        //     quantities
        // );
        // diamondContract.increaseBreedingProducedQuantities(
        //     TRUE_PLAYER,
        //     animalKindIds,
        //     quantities
        // );
        // PlantProducedInventoryItem[] memory producedItems = diamondContract
        //     .getPlantProducedInventoryItems(TRUE_PLAYER);
        // vm.stopPrank();

        // vm.startPrank(TRUE_PLAYER);
        // uint256[] memory fulfillOrderIndexes = new uint256[](1);
        // fulfillOrderIndexes[0] = 0;
        // diamondContract.fulfillOrders(fulfillOrderIndexes);
        // uint256 balanceBeforeClaim = diamondContract.getCurrencyBalance(
        //     TRUE_PLAYER
        // );
        // skip(1 hours);
        // diamondContract.claimOrders(fulfillOrderIndexes);
        // uint256 balanceAfterClaim = diamondContract.getCurrencyBalance(
        //     TRUE_PLAYER
        // );
        // assertEq(
        //     balanceAfterClaim - balanceBeforeClaim,
        //     orders[0].rewardAmount
        // );
        // vm.stopPrank();
        // UserProfile memory userProfileAfterClaim = diamondContract
        //     .getUserProfile(TRUE_PLAYER);
        // console.log(
        //     "User profile after claim: ",
        //     userProfileAfterClaim.exp,
        //     userProfileAfterClaim.level
        // );
    }

    function test_IncreaseExp() public {
        UserProfile memory userProfile = diamondContract.getUserProfile(
            TRUE_PLAYER
        );
        console.log("User profile: ", userProfile.exp, userProfile.level);
        vm.startPrank(BLUEPRINT);
        diamondContract.increaseExp(TRUE_PLAYER, 1000000);
        vm.stopPrank();
        UserProfile memory userProfileAfterIncrease = diamondContract
            .getUserProfile(TRUE_PLAYER);
        console.log(
            "User profile after increase: ",
            userProfileAfterIncrease.exp,
            userProfileAfterIncrease.level
        );
    }

    function test_RefreshOrder() public {
        vm.startPrank(TRUE_PLAYER);
        diamondContract.initLand{value: 1 ether}();
        vm.stopPrank();
        vm.startPrank(OP);
        diamondContract.airdropCurrency(TRUE_PLAYER, 1000000000000 ether);
        vm.stopPrank();
        vm.startPrank(TRUE_PLAYER);
        diamondContract.refreshOrders();
        OrderResponse[] memory orders = diamondContract.getOrders(TRUE_PLAYER);
        console.log("orders length: ", orders.length);
        console.log("Order 0: ", orders[0].requirements.length, "requirements");
        console.log("Order 0 expired at", orders[0].expiredAt);
        console.log("Order 0 reward amount", orders[0].rewardAmount);
        console.log("Order 0 exp reward amount", orders[0].expRewardAmount);
        skip(1 minutes);
        diamondContract.refreshOrders();

        OrderResponse[] memory ordersAfterRefresh = diamondContract.getOrders(
            TRUE_PLAYER
        );
        console.log("orders length: ", ordersAfterRefresh.length);
        console.log(
            "Order 0: ",
            ordersAfterRefresh[0].requirements.length,
            "requirements"
        );
        console.log("Order 0 expired at", ordersAfterRefresh[0].expiredAt);
        console.log(
            "Order 0 reward amount",
            ordersAfterRefresh[0].rewardAmount
        );

        assertNotEq(orders[0].rewardAmount, ordersAfterRefresh[0].rewardAmount);
        vm.stopPrank();
    }

    function test_RefreshOrderDelivering() public {
        vm.startPrank(TRUE_PLAYER);
        diamondContract.initLand{value: 1 ether}();
        diamondContract.refreshOrders();
        vm.prank(OP);
        diamondContract.airdropCurrency(TRUE_PLAYER, 1000000000000 ether);
        OrderResponse[] memory orders = diamondContract.getOrders(TRUE_PLAYER);
        console.log("orders length: ", orders.length);
        console.log("Order 0: ", orders[0].requirements.length, "requirements");
        console.log("Order 0 expired at", orders[0].expiredAt);
        console.log("Order 0 reward amount", orders[0].rewardAmount);
        vm.startPrank(BLUEPRINT);
        console.log("Start working to fulfill order 0");
        uint256[] memory seedIds = new uint256[](orders[0].requirements.length);
        uint256[] memory animalKindIds = new uint256[](
            orders[0].requirements.length
        );
        uint256[] memory quantities = new uint256[](
            orders[0].requirements.length
        );
        for (uint256 i = 0; i < orders[0].requirements.length; i++) {
            seedIds[i] = orders[0].requirements[i].seedId;
            quantities[i] = orders[0].requirements[i].quantity;
        }
        for (uint256 i = 0; i < orders[0].requirements.length; i++) {
            animalKindIds[i] = orders[0].requirements[i].animalKindId;
        }
        diamondContract.increasePlantProducedQuantities(
            TRUE_PLAYER,
            seedIds,
            quantities
        );
        diamondContract.increaseBreedingProducedQuantities(
            TRUE_PLAYER,
            animalKindIds,
            quantities
        );
        vm.stopPrank();

        vm.startPrank(TRUE_PLAYER);
        uint256[] memory fulfillOrderIndexes = new uint256[](1);
        fulfillOrderIndexes[0] = 0;
        diamondContract.fulfillOrders(fulfillOrderIndexes);
        skip(1 hours);
        diamondContract.refreshOrders();

        OrderResponse[] memory ordersAfterRefresh = diamondContract.getOrders(
            TRUE_PLAYER
        );
        console.log("orders length: ", ordersAfterRefresh.length);
        console.log(
            "Order 0: ",
            ordersAfterRefresh[0].requirements.length,
            "requirements"
        );
        console.log("Order 0 expired at", ordersAfterRefresh[0].expiredAt);
        console.log(
            "Order 0 reward amount",
            ordersAfterRefresh[0].rewardAmount
        );

        assertEq(orders[0].rewardAmount, ordersAfterRefresh[0].rewardAmount);
        assertTrue(
            ordersAfterRefresh[0].isFulfilled,
            "Order should be fulfilled"
        );
        diamondContract.claimOrders(fulfillOrderIndexes);
        skip(1 minutes);
        diamondContract.refreshOrders();
        OrderResponse[] memory ordersAfterRefresh2 = diamondContract.getOrders(
            TRUE_PLAYER
        );
        assertNotEq(
            ordersAfterRefresh2[0].rewardAmount,
            ordersAfterRefresh[0].rewardAmount
        );
        vm.stopPrank();
    }

    function test_BreedingCow() external {
        vm.startPrank(TRUE_PLAYER);
        diamondContract.initLand{value: 1 ether}();
        uint256 cowStableId = 2;
        diamondContract.unlockCowStableSlot(cowStableId);
        diamondContract.unlockCowStableSlot(cowStableId);
        diamondContract.feedCow(cowStableId, 0);
        diamondContract.feedCow(cowStableId, 1);
        skip(10 minutes);
        diamondContract.harvestCow(cowStableId, 0);
        diamondContract.harvestCow(cowStableId, 1);
        AnimalProducedInventoryItem[] memory producedItems = diamondContract
            .getBreedingProducedInventoryItems(TRUE_PLAYER);
        assertEq(producedItems[1].quantity, 6);
        vm.stopPrank();
    }

    function test_BreedingChicken() external {
        vm.startPrank(TRUE_PLAYER);
        UserProfile memory userProfile = diamondContract.getUserProfile(
            TRUE_PLAYER
        );
        console.log("User profile: ", userProfile.exp, userProfile.level);
        diamondContract.initLand();
        uint256 chickenCoopId = 12;
        diamondContract.unlockChickenCoopSlot(chickenCoopId);
        diamondContract.unlockChickenCoopSlot(chickenCoopId);
        diamondContract.feedChicken(chickenCoopId, 0);
        diamondContract.feedChicken(chickenCoopId, 1);
        skip(10 minutes);
        diamondContract.harvestChicken(chickenCoopId, 0);
        diamondContract.harvestChicken(chickenCoopId, 1);
        AnimalProducedInventoryItem[] memory producedItems = diamondContract
            .getBreedingProducedInventoryItems(TRUE_PLAYER);
        assertEq(producedItems[2].quantity, 10);
        vm.stopPrank();
    }

    function test_BuyItem() external {
        vm.startPrank(TRUE_PLAYER);
        diamondContract.initLand{value: 1 ether}();
        uint256[] memory items = diamondContract.getItemsOfOwner(TRUE_PLAYER);
        assertEq(items.length, 8);
        uint256 balanceBeforeBuy = diamondContract.getCurrencyBalance(
            TRUE_PLAYER
        );
        diamondContract.buyItem(ItemType.Crop, 1);
        uint256[] memory itemsAfterBuy = diamondContract.getItemsOfOwner(
            TRUE_PLAYER
        );
        uint256 balanceAfterBuy = diamondContract.getCurrencyBalance(
            TRUE_PLAYER
        );
        assertEq(itemsAfterBuy.length, 9);
        assertEq(balanceBeforeBuy - balanceAfterBuy, 50000 ether);
        vm.stopPrank();
    }

    // function test_Reclaim() external {
    //     vm.startPrank(RELAYER);
    //     // diamondContract.initLand();
    //     bytes memory initLandData = abi.encodeWithSignature("initLand()");
    //     _forwardRelayTx(initLandData, playerPrivateKey);
    //     uint256[] memory lands = diamondContract.getLandsOfOwner(TRUE_PLAYER);
    //     bytes memory reclaimLandData = abi.encodeWithSignature("reclaim(uint256,uint8,uint8)", lands[0], 0, 0);
    //     (bool sucess, ) = _forwardRelayTx(reclaimLandData, playerPrivateKey);
    //     assertFalse(sucess);
    //     // diamondContract.reclaim(lands[0], 2, 0);
    //     bytes memory reclaimLandData2 = abi.encodeWithSignature("reclaim(uint256,uint8,uint8)", lands[0], 2, 0);
    //     _forwardRelayTx(reclaimLandData2, playerPrivateKey);
    //     Plot memory plot = diamondContract.getPlot(lands[0], 2, 0);
    //     assertEq(uint8(plot.stage), uint8(PlotStage.Unlocked));
    //     vm.stopPrank();
    // }

    // function test_CantInitLandWhenPaused() external {
    //     vm.prank(OP);
    //     diamondContract.pause();
    //     vm.startPrank(RELAYER);
    //     // diamondContract.initLand();
    //     bytes memory initLandData = abi.encodeWithSignature("initLand()");
    //     (bool success, ) = _forwardRelayTx(initLandData, playerPrivateKey);
    //     assertFalse(success);
    //     vm.stopPrank();
    //     vm.prank(OP);
    //     diamondContract.unpause();
    //     _forwardRelayTx(initLandData, playerPrivateKey);
    // }
}
