// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Shop.sol";
import "../src/Cloneable.sol";

// @dev Tests for Shop Contract
contract ShopTest is Test {
    Shop public shop;
    Cloneable public cloneable;
    address payable private affiliate = payable(makeAddr("affiliate"));
    address payable private owner = payable(makeAddr("owner"));
    address payable private constant zeroAddress = payable(address(0));
    address payable private constant noAffiliate = zeroAddress;
    uint private fee = 100;

    receive() external payable {
    }

    function setUp() public {
        shop = new Shop();
        shop.initShop(owner, fee);

        cloneable = new Cloneable(address(shop));
    }

    event FeeChanged(uint fee);

    function test_setFee(uint newFee) public {
        vm.expectEmit(true, true, true, true, address(shop));
        emit FeeChanged(newFee);
        vm.prank(owner);
        shop.setFee(newFee);
        assertEq(shop.fee(), newFee);
    }

    function testFail_setFee(uint newFee) public {
        vm.prank(address(0));
        shop.setFee(newFee);
    }


    event Produced(address indexed source, address clone, address indexed user, address indexed affiliate, uint feePaid);

    function test_produceEvent() public {
        bytes memory initData;

        vm.expectEmit(true, true, true, false, address(shop));
        emit Produced(address(cloneable), address(0), address(this), affiliate, fee);
        shop.produce{value: fee}(cloneable, initData, affiliate);
        assertEq(owner.balance, fee / 2);

    }

    function test_produceWithAffiliate() public {
        bytes memory initData;

        Cloneable clone = Cloneable(
            shop.produce{value: fee}(cloneable, initData, affiliate)
        );

        assertEq(clone.owner(), address(this));
        assertEq(affiliate.balance, fee / 2);

        // Second produce should pay to the affiliate, even it not specified
        clone = Cloneable(
            shop.produce{value: fee}(cloneable, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
        assertEq(affiliate.balance, fee / 2 * 2);
    }

    function test_produceNoAffiliate() public {
        bytes memory initData;

        Cloneable clone = Cloneable(
            shop.produce{value: fee}(cloneable, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
        assertEq(owner.balance, fee);
    }

    function test_produceWrongValue() public {
        bytes memory initData;

        vm.expectRevert(Shop.WrongFeeValue.selector);
        shop.produce{value: 0}(cloneable, initData, zeroAddress);
    }

    function test_getAllUserContracts() public {
        bytes memory initData;
        assertEq(shop.getAllUserContracts(address(this)).length, 0);

        shop.produce{value: fee}(cloneable, initData, zeroAddress);
        assertEq(shop.getAllUserContracts(address(this)).length, 1);
        assertEq(owner.balance, fee);

        shop.produce{value: fee}(cloneable, initData, affiliate);
        assertEq(shop.getAllUserContracts(address(this)).length, 2);
        assertEq(owner.balance, fee + fee / 2);
    }


}
