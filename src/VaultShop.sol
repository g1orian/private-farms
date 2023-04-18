// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Shop.sol";
import "./interfaces/IPrivateVault.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

// @dev Cloning Vaults Shop Contract
// @author Bogdoslav
contract VaultShop is Shop {

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
        uint lastHardWork;
        uint prevHardWork;
        uint lastProfit;
    }

    function getVaultsInfo(address[] memory vaults)
    public view returns (VaultInfo[] memory info) {
        uint len = vaults.length;
        info = new VaultInfo[](len);
        for (uint i = 0; i < len; i++) {
            IPrivateVault vault = IPrivateVault(vaults[i]);
            info[i].vault = address(vault);
            info[i].name = vault.name();
            info[i].symbol = vault.symbol();
            info[i].TVL = vault.totalAssets();
            info[i].APR = vault.APR();
            info[i].lastHardWork = vault.lastHardWork();
            info[i].prevHardWork = vault.prevHardWork();
            info[i].lastProfit = vault.lastProfit();

            address asset = vault.asset();
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
