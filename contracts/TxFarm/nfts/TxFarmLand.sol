// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TxFarmLand is ERC721, ERC721Enumerable, AccessControl {
    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private _baseTokenURI;

    mapping(uint256 => bool) public lockedTokens;

    event LandLocked(uint256 indexed tokenId);
    event LandUnlocked(uint256 indexed tokenId);
    event LandMinted(
        address indexed to,
        uint256 indexed tokenId,
        bool isLocked
    );

    constructor() ERC721("TxFarm Land", "TxFL") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function setBaseURI(
        string memory baseURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI;
    }

    function unLock(uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        lockedTokens[tokenId] = false;
        emit LandUnlocked(tokenId);
    }

    function mint(
        address to,
        uint256 tokenId,
        bool isLocked
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
        if (isLocked) {
            lockedTokens[tokenId] = true;
            emit LandLocked(tokenId);
        }
        emit LandMinted(to, tokenId, isLocked);
    }

    function burn(uint256 tokenId) public {
        require(lockedTokens[tokenId] == false, "TxFarmLand: token is locked");
        _burn(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return string(abi.encodePacked(_baseURI(), tokenId.toString()));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        for (uint256 i = 0; i < batchSize; i++) {
            require(
                !lockedTokens[firstTokenId + i],
                "TxFarmLand: token is locked"
            );
        }
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
