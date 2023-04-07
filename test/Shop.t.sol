// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/main/Shop.sol";

// @dev Tests for Shop Contract
contract ShopTest is Test {
    Shop public shop;

    function setUp() public {
        shop = new Shop(100);
    }

    function testSetFee() public {
        shop.setFee(200);
        assertEq(shop.fee(), 200);
    }

    function testReturnOwnership() public {
        // TODO
    }
}
