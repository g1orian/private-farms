// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/main/Shop.sol";
import "../src/main/Clonable.sol";

// @dev Tests for Shop Contract
contract ShopTest is Test {
    Shop public shop;
    Clonable public clonable;
    Clonable public clonableNoDev;
    address payable public developer = payable(makeAddr("developer"));
    address payable public affiliate = payable(makeAddr("affiliate"));
    address payable public zeroAddress = payable(address(0));
    uint public fee = 100;
    uint public serviceRevenue;

    receive() external payable {
        assertEq(serviceRevenue, msg.value);
    }

    function setUp() public {
        shop = new Shop(fee);

        clonable = new Clonable(developer);
        clonable.transferOwnership(address(shop));

        clonableNoDev = new Clonable(zeroAddress);
        clonableNoDev.transferOwnership(address(shop));
    }

    function test_setFee(uint newFee) public {
        shop.setFee(newFee);
        assertEq(shop.fee(), newFee);
    }

    function testFail_setFee(uint newFee) public {
        vm.prank(address(0));
        shop.setFee(newFee);
    }

    function test_returnOwnership() public {
        assertEq(clonable.owner(), address(shop));
        shop.returnOwnership(address(clonable));
        assertEq(clonable.owner(), address(this));
    }

    function testFail_returnOwnership() public {
        vm.prank(address(0));
        shop.returnOwnership(address(clonable));
    }

    function test_produceWithAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee / 4;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonable, initData, affiliate)
        );

        assertEq(clone.owner(), address(this));
        assertEq(developer.balance, fee / 4);
        assertEq(affiliate.balance, fee / 2);
    }

    function test_produceNoAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee / 2;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonable, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
        assertEq(developer.balance, fee / 2);
    }

    function test_produceNoDevWithAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee / 2;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonableNoDev, initData, affiliate)
        );

        assertEq(clone.owner(), address(this));
        assertEq(affiliate.balance, fee / 2);
    }

    function test_produceNoDevNoAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonableNoDev, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
    }

    function test_produceWrongValue() public {
        bytes memory initData;

        vm.expectRevert(Shop.WrongValue.selector);
        shop.produce{value: 0}(clonable, initData, zeroAddress);
    }

    function test_produceNotMother() public {
        bytes memory initData;
        serviceRevenue = fee;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonableNoDev, initData, zeroAddress)
        );
        clone.transferOwnership(address(shop));
        vm.expectRevert(Clonable.NotMotherContract.selector);
        shop.produce{value: fee}(clone, initData, zeroAddress);
    }

    function test_produceCloneAlreadyInitialized() public {
        bytes memory initData;
        serviceRevenue = fee;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonableNoDev, initData, zeroAddress)
        );
        vm.expectRevert(Clonable.CloneAlreadyInitialized.selector);
        clone.initClone(address(this), initData);
    }

    function test_getAllUserContracts() public {
        bytes memory initData;
        assertEq(shop.getAllUserContracts(address(this)).length, 0);

        serviceRevenue = fee / 2;
        shop.produce{value: fee}(clonable, initData, zeroAddress);
        assertEq(shop.getAllUserContracts(address(this)).length, 1);

        serviceRevenue = fee;
        shop.produce{value: fee}(clonableNoDev, initData, zeroAddress);
        assertEq(shop.getAllUserContracts(address(this)).length, 2);
    }

}
