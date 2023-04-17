// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/VaultShop.sol";
import "../src/Clonable.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockVault.sol";

// @dev Tests for Shop Contract
contract ShopTest is Test {
    VaultShop public shop;
    MockVault public vault;
    IERC20 asset = new MockERC20("MockAsset", "MA", type(uint256).max);
    address payable public developer = payable(makeAddr("developer"));
    address payable public affiliate = payable(makeAddr("affiliate"));
    address payable public zeroAddress = payable(address(0));

    receive() external payable {
    }

    function setUp() public {
        shop = new VaultShop(0);

        vault = new MockVault('MockVault', 'MV', asset, developer);
        vault.transferOwnership(address(shop));

    }


    function test_getAllUserVaultsData() public {
        bytes memory initData;
        assertEq(shop.getAllUserVaultsInfo(address(this)).length, 0);

        address clone = shop.produce{value: 0}(vault, initData, zeroAddress);
        MockVault cloneVault = MockVault(payable(clone));
        uint deposit = 1000;
        asset.approve(address(cloneVault), deposit);
        cloneVault.deposit(deposit, address(this));
        uint lastProfit = 555;
        uint prevHardWork = 333;
        uint lastHardWork = 777;
        cloneVault.setLast(lastProfit, lastHardWork, prevHardWork);

        VaultShop.VaultInfo[] memory vaults = shop.getAllUserVaultsInfo(address(this));
        assertEq(vaults.length, 1);
        VaultShop.VaultInfo memory v = vaults[0];

        assertEq(v.vault, address(clone));
        assertEq(v.name, 'MockVault');
        assertEq(v.symbol, 'MV');
        assertEq(v.asset, address(asset));
        assertEq(v.assetSymbol, 'MA');
        assertEq(v.assetName, 'MockAsset');
        assertEq(v.TVL, deposit);
        assertEq(v.lastProfit, lastProfit);
        assertEq(v.prevHardWork, prevHardWork);
        assertEq(v.lastHardWork, lastHardWork);

        clone = shop.produce{value: 0}(vault, initData, zeroAddress);
        vaults = shop.getAllUserVaultsInfo(address(this));
        assertEq(vaults.length, 2);
        v = vaults[1];

        assertEq(v.vault, address(clone));
        assertEq(v.name, 'MockVault');
        assertEq(v.symbol, 'MV');
        assertEq(v.asset, address(asset));
        assertEq(v.assetSymbol, 'MA');
        assertEq(v.assetName, 'MockAsset');
        assertEq(v.TVL, 0);
        assertEq(v.APR, 0);
    }

    function test_getVaultsInfo() public {
        bytes memory initData;
        assertEq(shop.getAllUserVaultsInfo(address(this)).length, 0);

        address clone = shop.produce{value: 0}(vault, initData, zeroAddress);
        MockVault cloneVault = MockVault(payable(clone));
        uint deposit = 1000;
        asset.approve(address(cloneVault), deposit);
        cloneVault.deposit(deposit, address(this));

        address[] memory vaultAddresses = shop.getAllUserContracts(address(this));
        VaultShop.VaultInfo[] memory vaults = shop.getVaultsInfo(vaultAddresses);
        assertEq(vaults.length, 1);
        VaultShop.VaultInfo memory v = vaults[0];

        assertEq(v.vault, address(clone));
        assertEq(v.name, 'MockVault');
        assertEq(v.symbol, 'MV');
        assertEq(v.asset, address(asset));
        assertEq(v.assetSymbol, 'MA');
        assertEq(v.assetName, 'MockAsset');
        assertEq(v.TVL, deposit);
        assertEq(v.APR, 0);

    }


}
