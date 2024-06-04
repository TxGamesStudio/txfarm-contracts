// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {UserProfileStorage, UserProfile} from "../../shared/storage/UserProfileStorage.sol";
import {LibAppStorage} from "./LibAppStorage.sol";
import "hardhat/console.sol";

library LibUserProfile {

  function initUserProfile(address _user) internal {
    UserProfileStorage storage upS = LibAppStorage.userProfileStorage();
    UserProfile storage userProfile = upS.userProfiles[_user];
    userProfile.exp = upS.baseExp;
    userProfile.level = 1;
    userProfile.tier = 1;
  }

  function increaseExp(address _user, uint256 _amount) internal {
    UserProfileStorage storage upS = LibAppStorage.userProfileStorage();
    UserProfile storage userProfile = upS.userProfiles[_user];
    userProfile.exp += _amount;
    for (uint256 i = upS.levelToCummulativeExpThreshold.length; i > 0; i--) {
      if(userProfile.exp >= upS.levelToCummulativeExpThreshold[i - 1]) {
        userProfile.level = uint32(i);
        break;
      }
    }
    for (uint256 i = upS.levelToTierThreshold.length; i > 0; i--) {
      if (userProfile.level >= upS.levelToTierThreshold[i - 1]) {
        userProfile.tier = uint8(i);
        break;
      }
    }
  }

}