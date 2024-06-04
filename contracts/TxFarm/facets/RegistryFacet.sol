// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {PlayerAccount} from "../../shared/storage/RegistryStorage.sol";
import {LibRegistry} from "../libraries/LibRegistry.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RegistryFacet is Modifiers {
    event OperatorRegistered(address player, address operator, uint256 expiration);

    /// @notice Emitted when an Operator address is removed
    event OperatorDeregistered(address operator, address player);

    function getPlayerAccount(address operatorAddress) external view returns (address) {
        return LibRegistry.getPlayerAccount(operatorAddress);
    }

    function getOperatorAccountRegistrationMessageToSign(
        address player,
        address operator,
        uint256 expiration,
        uint256 blockNumber
    ) external pure returns (bytes memory) {
      return LibRegistry.getOperatorAccountRegistrationMessageToSign(player, operator, expiration, blockNumber);
    }

    function registerOperator(bytes calldata signature, address player, address operator, uint256 expiration, uint256 blockNumber) external {
        LibRegistry.registerOperator(signature, player, operator, expiration, blockNumber);
    }

    function deregisterOperator(address operator) external {
        LibRegistry.deregisterOperator(operator);
    }

    function getRegisteredOperators(address player) external view returns (address[] memory) {
        return LibRegistry.getRegisteredOperators(player);
    }
}
