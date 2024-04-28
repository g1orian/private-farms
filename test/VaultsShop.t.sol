// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/VaultShop.sol";
import "../src/Cloneable.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockVault.sol";

// @dev Tests for Shop Contract
contract ShopTest is Test {
    VaultShop public shop;
    MockVault public vault;
    address payable public owner;
    IERC20 public asset = new MockERC20("MockAsset", "MA", type(uint256).max);
    address payable public affiliate = payable(makeAddr("affiliate"));
    address payable public zeroAddress = payable(address(0));

    receive() external payable {
    }

    function setUp() public {
        owner = payable(address(this));
        shop = new VaultShop();
        shop.initShop(owner, 0);

        vault = new MockVault(address(shop), 'MockVault', 'MV', asset);
    }


/*    function test_getAllUserVaultsData() public {
        bytes memory initData;
        assertEq(shop.getAllUserVaultsInfo(address(this)).length, 0);

        address clone = shop.produce{value: 0}(vault, initData, zeroAddress);
        console.log('clone', clone);
        vm.label(clone, 'CLONE');

        MockVault cloneVault = MockVault(payable(clone));
        uint deposit = 1000;
        asset.approve(address(cloneVault), deposit);
        cloneVault.deposit(deposit, address(this));
        uint lastProfit = 555;
        uint prevHarvest = 333;
        uint lastHarvest = 777;
        cloneVault.setLast(lastProfit, lastHarvest, prevHarvest);

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
        assertEq(v.prevHarvest, prevHarvest);
        assertEq(v.lastHarvest, lastHarvest);

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
    }*/

    function test_getVaultsInfo() public {
        bytes memory initData;
        assertEq(shop.getAllUserVaultsInfo(address(this)).length, 0);

        address clone = shop.produce{value: 0}(vault, initData, zeroAddress);
        vm.label(clone, 'CLONE');
        MockVault cloneVault = MockVault(payable(clone));
        uint deposit = 1000;
        asset.approve(address(cloneVault), deposit);
        cloneVault.deposit(deposit, address(this));

        address[] memory vaultAddresses = shop.getAllUserContracts(address(this));
        VaultShop.VaultInfo[] memory vaults = shop.getVaultsInfo(vaultAddresses);
        assertEq(vaults.length, 1);
        VaultShop.VaultInfo memory v = vaults[0];

        assertEq(v.vault, address(clone));
        assertEq(v.name, 'PrivateVaultBase');
        assertEq(v.symbol, 'PVB');
        assertEq(v.asset, address(asset));
        assertEq(v.assetSymbol, 'MA');
        assertEq(v.assetName, 'MockAsset');
        assertEq(v.TVL, deposit);
        assertEq(v.APR, 0);

    }


}
