// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Shop.sol";
import "./interfaces/IPrivateVault.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

// @dev Cloning Vaults Shop Contract
// @author Bogdoslav
contract VaultShop is Shop {

    constructor(uint fee_) Shop(fee_) {}

    // ******** UI HELPER FUNCTIONS  ********

    struct VaultInfo {
        address vault;
        string name;
        string symbol;
        address asset;
        string assetSymbol;
        string assetName;
        uint TVL;
        uint APR;
    }

    function getVaultsInfo(address[] memory vaults)
    public view returns (VaultInfo[] memory info) {
        uint len = vaults.length;
        info = new VaultInfo[](len);
        for (uint i = 0; i < len; i++) {
            address vault = vaults[i];
            info[i].vault = vault;
            info[i].name = IPrivateVault(vault).name();
            info[i].symbol = IPrivateVault(vault).symbol();

            info[i].TVL = IPrivateVault(vault).totalAssets();
            info[i].APR = IPrivateVault(vault).APR();
            address asset = IPrivateVault(vault).asset();
            info[i].asset = asset;
            try IERC20Metadata(asset).symbol() returns (string memory symbol) {
                info[i].assetSymbol = symbol;
            } catch {
                info[i].assetSymbol = "";
            }
            try IERC20Metadata(asset).name() returns (string memory name) {
                info[i].assetName = name;
            } catch {
                info[i].assetName = "";
            }
        }
    }

    function getAllUserVaultsInfo(address user)
    external view returns (VaultInfo[] memory) {
        return getVaultsInfo(getAllUserContracts(user));
    }



}
