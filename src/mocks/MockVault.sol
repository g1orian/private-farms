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
     */
    constructor(address owner_, string memory name_, string memory symbol_, IERC20 asset_)
    PrivateVaultBase(owner_, name_, symbol_, asset_) {
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
    function _claimRewardsAndConvertToAsset() internal override {
        // just do nothing
    }

    /**
     * @dev Set last profit and last hard work for APR calculation testing purposes
     */
    function setLast(uint lastProfit_, uint lastHarvest_, uint prevHarvest_) external onlyOwner {
        lastProfit = lastProfit_;
        lastHarvest = lastHarvest_;
        prevHarvest = prevHarvest_;
    }
}
