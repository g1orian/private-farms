// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @title Base Private Vault Contract
// @notice initialize() used instead of constructor to work with proxy pattern
abstract contract PrivateVaultBase {
    address owner;

    error AlreadyInitialized();
    error ZeroParameter();

    function initialize(address owner_)
    external {
        if (owner != address(0)) revert AlreadyInitialized();
        if (owner_ == address(0)) revert ZeroParameter();
        owner = payable(owner_);
        // TODO
    }

    // TODO ether salvage
    // TODO ERC20 salvage
    // TODO NFT salvage

}
