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
    uint public shouldReceive;

    receive() external payable {
        assertEq(shouldReceive, msg.value);
    }

    function setUp() public {
        shop = new Shop(fee);

        clonable = new Clonable(developer);
        clonableNoDev = new Clonable(zeroAddress);
        clonable.transferOwnership(address(shop));
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

    function test_produce() public {
        bytes memory initData;
        shouldReceive = fee / 2;

        Clonable clone = Clonable(
            shop.produce{value: fee}(clonable, initData, zeroAddress)
        );

        assertEq(clone.owner(), address(this));
    }

}
