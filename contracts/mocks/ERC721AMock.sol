// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import "erc721a/contracts/ERC721A.sol";

contract ERC721AMock is ERC721A {

    constructor() ERC721A("ERC721AMock", "ERC721AMock") {}

    function mint(address to, uint256 quantity) external{
        _safeMint(to, quantity);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
