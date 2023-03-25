// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./oz/token/ERC20/extensions/ERC4626.sol";
import "./oz/access/Ownable.sol";
import "./oz/proxy/Clones.sol";
import "./interfaces/IClonable.sol";

// @title Base Private Vault Contract
// @notice initialize() used instead of constructor to work with proxy pattern
abstract contract PrivateVaultBase is IClonable, Ownable, ERC4626 {

    bool private motherContract; // it will be false at cloned contracts

    event Cloned(address cloneContract, address indexed forClient);

    error AlreadyInitialized();
    error ZeroParameter();
    error NotMotherContract();

    constructor(IERC20 asset_) Ownable() ERC4626(asset_) {
        motherContract = true;
    }

    function clone(address client)
    onlyOwner external override returns (address newClone) {
        if (!motherContract) revert NotMotherContract();
        newClone = Clones.clone(address(this));
        PrivateVaultBase(newClone).initClone(client);
        emit Cloned(newClone, client);
    }

    function initClone(address client)
    external override virtual {
        if (owner() != address(0)) revert AlreadyInitialized();
        _transferOwnership(client);
    }

    function deposit(uint256 assets, address receiver)
    onlyOwner public override returns (uint256 shares) {
        return super.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver)
    onlyOwner public override returns (uint256 assets) {
        return super.mint(shares, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner)
    onlyOwner public override returns (uint256 shares) {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
    onlyOwner public override returns (uint256 assets) {
        return super.redeem(shares, receiver, owner);
    }


    // TODO ether salvage
    // TODO ERC20 salvage
    // TODO NFT salvage

}
