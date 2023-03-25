// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./oz/token/ERC20/extensions/ERC4626.sol";
import "./oz/access/Ownable.sol";

// @title Base Private Vault Contract
// @notice initialize() used instead of constructor to work with proxy pattern
abstract contract PrivateVaultBase is Ownable, ERC4626 {

    error AlreadyInitialized();
    error ZeroParameter();

    function initialize(address owner_)
    external {
        if (owner() != address(0)) revert AlreadyInitialized();
        _transferOwnership(owner_);
        // TODO
    }

//    function deposit(uint256 assets, address receiver)
//    external override returns (uint256 shares)


    // TODO ether salvage
    // TODO ERC20 salvage
    // TODO NFT salvage

}
