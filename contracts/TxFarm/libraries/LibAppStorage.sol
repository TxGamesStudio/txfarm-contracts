// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { PausableStorage } from "../../shared/storage/PausableStorage.sol";
import { LandStorage } from "../../shared/storage/LandStorage.sol";
import { CurrencyStorage } from "../../shared/storage/CurrencyStorage.sol";
import { StoreStorage } from "../../shared/storage/StoreStorage.sol";
import { OrderStorage } from "../../shared/storage/OrderStorage.sol";
import { InventoryStorage } from "../../shared/storage/InventoryStorage.sol";
import { ItemsStorage } from "../../shared/storage/ItemsStorage.sol";
import { RegistryStorage } from "../../shared/storage/RegistryStorage.sol";
import { UserProfileStorage } from "../../shared/storage/UserProfileStorage.sol";
import { EIP2771Storage } from "../../shared/storage/EIP2771Storage.sol";
import { ConfigStorage } from "../../shared/storage/ConfigStorage.sol";
import { CraftingStorage } from "../../shared/storage/CraftingStorage.sol";

import { AccessControlStorage } from "../../shared/storage/AccessControlStorage.sol";
import { EIP712NonceStorage } from "../../shared/storage/EIP712NonceStorage.sol";
import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";
import { LibMeta } from "../../shared/libraries/LibMeta.sol";
import { LibAccessControl } from "../../shared/libraries/LibAccessControl.sol";

import { EIP712DomainData } from "./LibMetaTransaction.sol";
import { LibMetaTransaction, MetaPackedData } from "./LibMetaTransaction.sol";

import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

struct AppStorage {
    uint256 version;
}

library LibAppStorage {
    bytes32 public constant EIP712Nonce_STORAGE_POSITION = keccak256("EIP712Nonce.storage.position");
    bytes32 public constant EIP712DomainData_STORAGE_POSITION = keccak256("EIP712DomainData.storage.position");
    bytes32 public constant PausableStorage_STORAGE_POSITION = keccak256("PausableStorage.storage.position");
    bytes32 public constant AccessControlStorage_STORAGE_POSITION = keccak256("AccessControlStorage.storage.position");
    
    bytes32 public constant LandStorage_STORAGE_POSITION = keccak256("LandStorage.storage.position");
    bytes32 public constant CurrencyStorage_STORAGE_POSITION = keccak256("CurrencyStorage.storage.position");
    bytes32 public constant StoreStorage_STORAGE_POSITION = keccak256("StoreStorage.storage.position");
    bytes32 public constant OrderStorage_STORAGE_POSITION = keccak256("OrderStorage.storage.position");
    bytes32 public constant InventoryStorage_STORAGE_POSITION = keccak256("InventoryStorage.storage.position");
    bytes32 public constant RegistryStorage_STORAGE_POSITION = keccak256("RegistryStorage.storage.position"); 
    bytes32 public constant ItemsStorage_STORAGE_POSITION = keccak256("ItemsStorage.storage.position");
    bytes32 public constant UserProfileStorage_STORAGE_POSITION = keccak256("UserProfileStorage.storage.position");
    bytes32 public constant ConfigStorage_STORAGE_POSITION = keccak256("ConfigStorage.storage.position");
    bytes32 public constant CraftingStorage_STORAGE_POSITION = keccak256("CraftingStorage.storage.position");

    bytes32 public constant EIP2771Storage_STORAGE_POSITION = keccak256("EIP2771Storage.storage.position");


    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function eip712NonceStorage() internal pure returns (EIP712NonceStorage storage ds) {
        bytes32 position = EIP712Nonce_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function eip712DomainDataStorage() internal pure returns(EIP712DomainData storage ds) {
        bytes32 position = EIP712DomainData_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function pausableStorage() internal pure returns(PausableStorage storage ds) {
        bytes32 position = PausableStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function accessControlStorage() internal pure returns(AccessControlStorage storage ds) {
        bytes32 position = AccessControlStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function landStorage() internal pure returns(LandStorage storage ds) {
        bytes32 position = LandStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function currencyStorage() internal pure returns(CurrencyStorage storage ds) {
        bytes32 position = CurrencyStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function storeStorage() internal pure returns(StoreStorage storage ds) {
        bytes32 position = StoreStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function orderStorage() internal pure returns(OrderStorage storage ds) {
        bytes32 position = OrderStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function inventoryStorage() internal pure returns(InventoryStorage storage ds) {
        bytes32 position = InventoryStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function registryStorage() internal pure returns(RegistryStorage storage ds) {
        bytes32 position = RegistryStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function eip2771Storage() internal pure returns(EIP2771Storage storage ds) {
        bytes32 position = EIP2771Storage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function itemsStorage() internal pure returns(ItemsStorage storage ds) {
        bytes32 position = ItemsStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function userProfileStorage() internal pure returns(UserProfileStorage storage ds) {
        bytes32 position = UserProfileStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function configStorage() internal pure returns(ConfigStorage storage ds) {
        bytes32 position = ConfigStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function craftingStorage() internal pure returns(CraftingStorage storage ds) {
        bytes32 position = CraftingStorage_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

contract Modifiers {
    AppStorage internal s;

    modifier signatureVerified(bytes4 selector, MetaPackedData calldata req, bytes calldata signature) {
        LibMetaTransaction.verify(selector, req, signature);
        LibAppStorage.eip712NonceStorage().used[req.nonce] = true;

        _;
    }

    modifier signatureVerifiedWithSender(
        bytes4 selector, MetaPackedData calldata req, bytes calldata signature, address sender
    ) {
        LibMetaTransaction.verify(selector, req, signature, sender);
        LibAppStorage.eip712NonceStorage().used[req.nonce] = true;

        _;
    }

    modifier onlyRole(bytes32 role) {
        LibAccessControl.checkRole(LibAppStorage.accessControlStorage(), role);
        _;
    }

    modifier onlyFromDiamond() {
        require(msg.sender == address(this), "internal call only!");
        _;
    }

    modifier whenNotPaused() {
        require(!LibAppStorage.pausableStorage().paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(LibAppStorage.pausableStorage().paused, "Pausable: not paused");
        _;
    }

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }
}
