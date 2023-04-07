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
    address payable public developer = payable(address(this));

    function setUp() public {
        shop = new Shop(100);

        clonable = new Clonable(developer);
        clonableNoDev = new Clonable(payable(address(0)));
        clonable.transferOwnership(address(shop));
    }

    function test_setFee(uint fee) public {
        shop.setFee(fee);
        assertEq(shop.fee(), fee);
    }

    function testFail_setFee(uint fee) public {
        vm.prank(address(0));
        shop.setFee(fee);
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

}
