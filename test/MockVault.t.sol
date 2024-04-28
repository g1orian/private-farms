// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/mocks/MockVault.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

// @dev Tests for MockVault (PrivateVaultBase) Contract
contract MockVaultTest is Test {
    MockVault public vault;
    string public name = "MockVault";
    string public symbol = "MV";
    IERC20 public asset = new MockERC20("MockAsset", "MA", type(uint256).max);

    address payable constant public zeroAddress = payable(address(0));

    function setUp() public {
        vault = new MockVault(address(this), name, symbol, asset);
        asset.approve(address(vault), type(uint).max);
    }

    // init clone

    function test_initCloneNoData() public {
        MockVault clone = MockVault(
            vault.clone(address(this), '')
        );
        // TODO
    }

    // doWork

    function test_doWork_NoWork() public {
        vm.expectRevert(PrivateVaultBase.NoProfitableWork.selector);
        vault.doWork();
    }

    function test_doWork() public {
        vault.deposit(1, address(this));
        vault.doWork();
    }

    // deposit / withdrawal

    // @notice investedAssets() is always 0 in MockVault
    function test_investedAssets() public view {
        assertEq(vault.investedAssets(), 0);
    }

    function test_APR() public {
        assertEq(vault.APR(), 0);

        vault.deposit(10, address(this));
        // 10% = 0,1 18 decimals
        vault.setLast(1, block.timestamp + 365 days, block.timestamp);
        assertEq(vault.APR(), 10**18 / 10);
        // 365% = 3,65 18 decimals
        vault.setLast(1, block.timestamp + 1 days, block.timestamp);
        assertEq(vault.APR(), 10**18 / 10 * 365);

    }

    function test_deposit_NotOwner() public {
        vm.prank(zeroAddress);
        vm.expectRevert(Cloneable.NotOwner.selector);
        vault.deposit(1, address(this));
    }

    function test_withdraw_NotOwner() public {
        vm.prank(zeroAddress);
        vm.expectRevert(Cloneable.NotOwner.selector);
        vault.withdraw(1, address(this), address(this));
    }

    function test_mint_NotOwner() public {
        vm.prank(zeroAddress);
        vm.expectRevert(Cloneable.NotOwner.selector);
        vault.mint(1, address(this));
    }

    function test_redeem_NotOwner() public {
        vm.prank(zeroAddress);
        vm.expectRevert(Cloneable.NotOwner.selector);
        vault.redeem(1, address(this), address(this));
    }

    function test_deposit(uint amount) public {
        uint assetsBefore = asset.balanceOf(address(this));

        vault.deposit(amount, address(this));
        assertEq(vault.totalAssets(), amount);

        uint assetsAfter = asset.balanceOf(address(this));
        assertEq(assetsBefore - amount, assetsAfter);

    }

    function test_mint(uint amount) public {
        uint assetsBefore = asset.balanceOf(address(this));

        vault.mint(amount, address(this));
        assertEq(vault.totalAssets(), amount);

        uint assetsAfter = asset.balanceOf(address(this));
        assertEq(assetsBefore - amount, assetsAfter);

    }

    function test_withdraw(uint128 amount) public {
        uint assetsBefore = asset.balanceOf(address(this));

        vault.deposit(amount, address(this));
        assertEq(vault.totalAssets(), amount);
        vault.withdraw(amount, address(this), address(this));
        assertEq(vault.totalAssets(), 0);

        uint assetsAfter = asset.balanceOf(address(this));
        assertEq(assetsBefore, assetsAfter);
    }

    function test_redeem(uint128 amount) public {
        uint assetsBefore = asset.balanceOf(address(this));

        vault.deposit(amount, address(this));
        assertEq(vault.totalAssets(), amount);
        uint shares = IERC20(vault).balanceOf(address(this));
        vault.redeem(shares, address(this), address(this));
        assertEq(vault.totalAssets(), 0);

        uint assetsAfter = asset.balanceOf(address(this));
        assertEq(assetsBefore, assetsAfter);
    }

    // salvages

    receive() external payable {}

    function test_salvage_NotOwner() public {
        vm.prank(zeroAddress);
        vm.expectRevert(Cloneable.NotOwner.selector);
        vault.salvage(1);
    }

    function test_salvageERC20_NotOwner() public {
        vm.prank(zeroAddress);
        vm.expectRevert(Cloneable.NotOwner.selector);
        vault.salvageERC20(address(asset), 1);
    }

    function test_salvage(uint16 amount) public {
        payable(address(vault)).transfer(amount);
        uint balanceBefore = address(this).balance;
        vault.salvage(amount);
        uint balanceAfter = address(this).balance;
        assertEq(balanceBefore + amount, balanceAfter);
    }

    function test_salvage_0(uint16 amount) public {
        payable(address(vault)).transfer(amount);
        uint balanceBefore = address(this).balance;
        vault.salvage(0);
        uint balanceAfter = address(this).balance;
        assertEq(balanceBefore + amount, balanceAfter);
    }

    function test_salvageERC20(uint16 amount) public {
        asset.transfer(address(vault), amount);
        uint balanceBefore = asset.balanceOf(address(this));
        vault.salvageERC20(address(asset), amount);
        uint balanceAfter = asset.balanceOf(address(this));
        assertEq(balanceBefore + amount, balanceAfter);
    }

    function test_salvageERC20_0(uint16 amount) public {
        asset.transfer(address(vault), amount);
        uint balanceBefore = asset.balanceOf(address(this));
        vault.salvageERC20(address(asset), 0);
        uint balanceAfter = asset.balanceOf(address(this));
        assertEq(balanceBefore + amount, balanceAfter);
    }

    function onERC721Received(address /*operator*/, address /*from*/, uint256 /*tokenId*/, bytes memory /*data*/)
    external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }


}
