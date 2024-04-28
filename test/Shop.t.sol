// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Shop.sol";
import "../src/Cloneable.sol";

// @dev Tests for Shop Contract
contract ShopTest is Test {
    Shop public shop;
    Cloneable private cloneable;
    Cloneable private cloneableNoDev;
    address payable private developer = payable(makeAddr("developer"));
    address payable private affiliate = payable(makeAddr("affiliate"));
    address payable private constant zeroAddress = payable(address(0));
    uint private fee = 100;
    uint private serviceRevenue;

    receive() external payable {
        assertEq(serviceRevenue, msg.value);
    }

    function setUp() public {
        shop = new Shop();
        shop.setFee(fee);

        cloneable = new Cloneable(address(shop));
    }

    event FeeChanged(uint fee);

    function test_setFee(uint newFee) public {
        vm.expectEmit(true, true, true, true, address(shop));
        emit FeeChanged(newFee);
        shop.setFee(newFee);
        assertEq(shop.fee(), newFee);
    }

    function testFail_setFee(uint newFee) public {
        vm.prank(address(0));
        shop.setFee(newFee);
    }

    function test_returnOwnership() public {
        assertEq(cloneable.owner(), address(shop));
        shop.returnOwnership(address(cloneable));
        assertEq(cloneable.owner(), address(this));
    }

    function testFail_returnOwnership() public {
        vm.prank(address(0));
        shop.returnOwnership(address(cloneable));
    }

    event Produced(address indexed source, address clone, address indexed user, address indexed affiliate, uint feePaid);

    function test_produceEvent() public {
        bytes memory initData;
        serviceRevenue = fee / 4;

        vm.expectEmit(true, true, true, false, address(shop));
        emit Produced(address(cloneable), address(0), address(this), affiliate, fee);
        shop.produce{value: fee}(cloneable, initData, affiliate);
    }

    function test_produceWithAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee / 4;

        Cloneable clone = Cloneable(
            shop.produce{value: fee}(cloneable, initData, affiliate)
        );

        assertEq(clone.owner(), address(this));
        assertEq(developer.balance, fee / 4);
        assertEq(affiliate.balance, fee / 2);

        // Second produce should pay to the affiliate, even it not specified
        clone = Cloneable(
            shop.produce{value: fee}(cloneable, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
        assertEq(developer.balance, fee / 4 * 2);
        assertEq(affiliate.balance, fee / 2 * 2);
    }

    function test_produceNoAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee / 2;

        Cloneable clone = Cloneable(
            shop.produce{value: fee}(cloneable, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
        assertEq(developer.balance, fee / 2);
    }

    function test_produceNoDevWithAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee / 2;

        Cloneable clone = Cloneable(
            shop.produce{value: fee}(cloneableNoDev, initData, affiliate)
        );

        assertEq(clone.owner(), address(this));
        assertEq(affiliate.balance, fee / 2);
    }

    function test_produceNoDevNoAffiliate() public {
        bytes memory initData;
        serviceRevenue = fee;

        Cloneable clone = Cloneable(
            shop.produce{value: fee}(cloneableNoDev, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
    }

    function test_produceWrongValue() public {
        bytes memory initData;

        vm.expectRevert(Shop.WrongFeeValue.selector);
        shop.produce{value: 0}(cloneable, initData, zeroAddress);
    }

    function test_getAllUserContracts() public {
        bytes memory initData;
        assertEq(shop.getAllUserContracts(address(this)).length, 0);

        serviceRevenue = fee;
        shop.produce{value: fee}(cloneable, initData, zeroAddress);
        assertEq(shop.getAllUserContracts(address(this)).length, 1);

        serviceRevenue = fee;
        shop.produce{value: fee}(cloneableNoDev, initData, zeroAddress);
        assertEq(shop.getAllUserContracts(address(this)).length, 2);
    }


}
