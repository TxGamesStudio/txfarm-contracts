// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {PlayerAccount, RegistryStorage} from "../../shared/storage/RegistryStorage.sol";
import {LibEIP2771} from "./LibEIP2771.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "hardhat/console.sol";

library LibRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;

    // @notice Operator registration cooldown time in secons
    uint256 public constant REGISTER_OPERATOR_COOLDOWN_LIMIT = 60 * 2; // 2 minutes

    event OperatorRegistered(address player, address operator, uint256 expiration);

    /// @notice Emitted when an Operator address is removed
    event OperatorDeregistered(address operator, address player);

    function playerAccount() internal view returns (address) {
        return getPlayerAccount(LibEIP2771.msgSender());
    }

    function getPlayerAccount(address operatorAddress) internal view returns (address) {
        require(operatorAddress != address(0), "Invalid operator address");

        PlayerAccount memory account = LibAppStorage.registryStorage().operatorToPlayerAccount[operatorAddress];

        address playerAddress = account.playerAddress;

        if (playerAddress != address(0)) {
            if (account.expiration < block.timestamp && account.expiration != 0) {
                revert("Operator address expired");
            }
        } else {
            return operatorAddress;
        }

        return playerAddress;
    }

    function getOperatorAccountRegistrationMessageToSign(
        address player,
        address operator,
        uint256 expiration,
        uint256 blockNumber
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                "Authorize operator account ",
                Strings.toHexString(uint256(uint160(operator)), 20),
                " to perform gameplay actions on behalf of player account ",
                Strings.toHexString(uint256(uint160(player)), 20),
                " with expiration ",
                Strings.toString(expiration),
                " signed at block ",
                Strings.toString(blockNumber)
            );
    }

    function registerOperator(bytes calldata signature, address player, address operator, uint256 expiration, uint256 blockNumber) internal {
        RegistryStorage storage rs = LibAppStorage.registryStorage();
        if (LibEIP2771.msgSender() != operator) {
            revert("Invalid caller");
        }
        if ((block.timestamp - rs.lastRegisterOperatorTime[player]) < REGISTER_OPERATOR_COOLDOWN_LIMIT) {
            revert("Operator registration cooldown not expired");
        }
        if (operator == player || operator == address(0)) {
            revert("Invalid operator address");
        }
        if (expiration < block.timestamp && expiration != 0) {
            revert("Invalid expiration time");
        }

        PlayerAccount memory currentAccount = rs.operatorToPlayerAccount[operator];

        if (currentAccount.playerAddress != address(0) && currentAccount.playerAddress != player) {
            revert("Operator already registered to a different player");
        }

        bytes memory message = getOperatorAccountRegistrationMessageToSign(player, operator, expiration, blockNumber);
        bytes32 digest = ECDSA.toEthSignedMessageHash(message);
        address recoveredSigner = ECDSA.recover(digest, signature);

        if (player != recoveredSigner) {
            revert("Invalid signature");
        }

        rs.operatorToPlayerAccount[operator] = PlayerAccount({playerAddress: player, expiration: expiration});

        rs.playerToOperatorAddresses[player].add(operator);

        // Track cooldown timer
        rs.lastRegisterOperatorTime[player] = block.timestamp;

        emit OperatorRegistered(player, operator, expiration);
    }

    /**
     * Called by an Operator or Player to deregister an Operator account
     *
     * @param operatorToDeregister address of operator to deregister
     */
    function deregisterOperator(address operatorToDeregister) internal {
        RegistryStorage storage rs = LibAppStorage.registryStorage();
        address playerAddress = rs.operatorToPlayerAccount[operatorToDeregister].playerAddress;

        if (playerAddress == address(0)) {
            revert("Operator not registered");
        }
        if (operatorToDeregister != LibEIP2771.msgSender() && playerAddress != LibEIP2771.msgSender()) {
            revert("Invalid caller");
        }

        delete rs.operatorToPlayerAccount[operatorToDeregister];

        bool operatorRemovedFromPlayer = rs.playerToOperatorAddresses[playerAddress].remove(operatorToDeregister);

        if (operatorRemovedFromPlayer != true) {
            revert("Operator not removed to player");
        }

        emit OperatorDeregistered(operatorToDeregister, playerAddress);
    }

    function getRegisteredOperators(address player) internal view returns (address[] memory) {
        RegistryStorage storage rs = LibAppStorage.registryStorage();
        return rs.playerToOperatorAddresses[player].values();
    }
}
