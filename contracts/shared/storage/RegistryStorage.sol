// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/// @notice Player Account structure
struct PlayerAccount {
    address playerAddress;
    uint256 expiration;
}

struct RegistryStorage {
    /// @notice Registry of current operator address to the player account
    mapping(address => PlayerAccount) operatorToPlayerAccount;
    /// @notice Registry of player account mapped to authorized operators
    mapping(address => EnumerableSet.AddressSet) playerToOperatorAddresses;
    /// @notice Last time the player registered an operator wallet
    mapping(address => uint256) lastRegisterOperatorTime;
}
