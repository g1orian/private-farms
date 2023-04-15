// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../PrivateVaultBase.sol";

// @title Mock Private Vault Contract
// @author Bogdoslav
contract MockVault is PrivateVaultBase {

    /**
     * @dev Constructor
     * @param name_ name of the vault
     * @param symbol_ symbol of the vault
     * @param asset_ address of the vault asset
     * @param developer_ address of the contract developer (to share revenue)
     */
    constructor(string memory name_, string memory symbol_, IERC20 asset_, address payable developer_)
    PrivateVaultBase(name_, symbol_, asset_, developer_) {
    }

    /**
     * @dev Should return how much assets invested / staked
     *    - used to calculate total assets
     */
    function investedAssets() public pure override returns (uint) {
        return 0;
    }

    /**
     * @dev Should invest / stake free assets from the vault
     * @param assets amount of assets to invest
     */
    function _invest(uint assets) internal override {
        // just do nothing
    }

    /**
     * @dev Should de-vest / un-stake assets from the underlying protocol to the vault
     *    - if available amount less then requested, then do not revert and withdraw all available
     * @param assets amount of assets to de-vest
     */
    function _divest(uint assets) internal override {
        // just do nothing
    }

    /**
     * @dev Should claim all rewards
     */
    function _claimRewards() internal override {
        // just do nothing
    }

    /**
     * @dev Should convert rewards to asset
     *    - check and skip conversion when no rewards
     */
    function _convertRewardsToAsset() internal override {
        // just do nothing
    }

}
