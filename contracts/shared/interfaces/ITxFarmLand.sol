// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ITxFarmLand is IERC721Enumerable {
    function mint(address to, uint256 tokenId, bool isLocked) external;
    function unlock(uint256 tokenId) external;
}
