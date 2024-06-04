// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct UserProfile {
    uint256 exp;
    uint32 level;
    uint8 tier;
    string username;
}

struct UserProfileStorage {
    uint256 totalUsers;
    mapping(address => bool) isInitialized;
    mapping(address => UserProfile) userProfiles;
    uint256 baseExp;
    uint256 levelCoefRate;
    uint256[] levelToTierThreshold;
    uint256[] levelToCummulativeExpThreshold;
}