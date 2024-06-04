// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AppStorage, LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {UserProfile} from "../../shared/storage/UserProfileStorage.sol";
import {LibAccessControl} from "../../shared/libraries/LibAccessControl.sol";
import {LibUserProfile} from "../libraries/LibUserProfile.sol";
import {LibCurrency} from "../libraries/LibCurrency.sol";
import {UserProfileStorage} from "../../shared/storage/UserProfileStorage.sol";

contract UserProfileFacet is Modifiers {
    struct UserProfileResponse {
        uint256 exp;
        uint32 level;
        uint8 tier;
        string username;
        uint256 balance;
    }

    function getUserProfile(address _user) external view returns (UserProfileResponse memory) {
        UserProfile memory userProfile = LibAppStorage.userProfileStorage().userProfiles[_user];
        return UserProfileResponse({
            exp: userProfile.exp,
            level: userProfile.level,
            tier: userProfile.tier,
            username: userProfile.username,
            balance: LibCurrency.getCurrencyBalance(_user)
        });
    }

    function increaseExp(address _user, uint256 _amount) external onlyRole(LibAccessControl.BLUEPRINT_ROLE){
        LibUserProfile.increaseExp(_user, _amount);
    }

    function getUserProfileConfig() external view returns (uint256 baseExp, uint256 levelCoefRate) {
        UserProfileStorage storage upS = LibAppStorage.userProfileStorage();
        return (upS.baseExp, upS.levelCoefRate);
    }
}