// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { AccessControlStorage } from "../storage/AccessControlStorage.sol";

library LibAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    bytes32 internal constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");                         // 9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6
    bytes32 internal constant OP_ROLE = keccak256("OP_ROLE");                                 // 9634689da3e320d3851bdfd82b5581ce1042c9b202afe8c26d4e6d92dfaf0cde
    bytes32 internal constant BLUEPRINT_ROLE = keccak256("BLUEPRINT_ROLE");                   // 2b6c2b18b389f3c429a455061a676383bb65a69b3815165975e1e70f13f6e016
    bytes32 internal constant FINANCIAL_ROLE = keccak256("FINANCIAL_ROLE");                   // 5245999133c6d8d4571d82773bdec82e2a254d49eae8d487e9867b56643d7333
    bytes32 internal constant SIGNER_ROLE = keccak256("SIGNER_ROLE");                         // e2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70

    function hasRole(AccessControlStorage storage s, bytes32 role, address account) internal view returns (bool) {
        return s.roles[role].members[account];
    }

    function checkRole(AccessControlStorage storage s, bytes32 role) internal view {
        checkRole(s, role, msg.sender);
    }

    function checkRole(AccessControlStorage storage s, bytes32 role, address account) internal view {
        if (!hasRole(s, role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(AccessControlStorage storage s, bytes32 role) internal view returns (bytes32) {
        return s.roles[role].adminRole;
    }

    function setupRole(AccessControlStorage storage s, bytes32 role, address account) internal {
        grantRole(s, role, account);
    }

    function setRoleAdmin(AccessControlStorage storage s, bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(s, role);
        s.roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function grantRole(AccessControlStorage storage s, bytes32 role, address account) internal {
        if (!hasRole(s, role, account)) {
            s.roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function revokeRole(AccessControlStorage storage s, bytes32 role, address account) internal {
        if (hasRole(s, role, account)) {
            s.roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}