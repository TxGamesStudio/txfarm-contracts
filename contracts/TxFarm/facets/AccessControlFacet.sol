// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { AppStorage, LibAppStorage, Modifiers } from "../libraries/LibAppStorage.sol";
import { LibAccessControl } from "../../shared/libraries/LibAccessControl.sol";

contract AccessControlFacet is Modifiers {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return LibAccessControl.hasRole(LibAppStorage.accessControlStorage(), role, account);
    }

    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return LibAppStorage.accessControlStorage().roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        LibAccessControl.grantRole(LibAppStorage.accessControlStorage(), role, account);
    }

    function grantRoleForMany(bytes32 role, address[] memory accounts) public virtual onlyRole(getRoleAdmin(role)) {
        for (uint8 i = 0; i < accounts.length; i++) {
            LibAccessControl.grantRole(LibAppStorage.accessControlStorage(), role, accounts[i]);
        }
    }

    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        LibAccessControl.revokeRole(LibAppStorage.accessControlStorage(), role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == msg.sender, "AccessControl: can only renounce roles for self");

        LibAccessControl.revokeRole(LibAppStorage.accessControlStorage(), role, account);
    }
}
