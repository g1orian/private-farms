// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 tokenId
    ) ERC721(name, symbol) {
        _safeMint(msg.sender, tokenId);
    }
}
