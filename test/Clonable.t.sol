// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Clonable.sol";

// @dev Tests for Clonable Contract
contract ClonableTest is Test {
    Clonable public clonable;
    Clonable public clonableZeroDev;
    address payable public developer = payable(makeAddr("developer"));
    address payable public zeroAddress = payable(address(0));

    function setUp() public {
        clonable = new Clonable(developer);
        clonableZeroDev = new Clonable(zeroAddress);
    }

    function test_developer() public {
        assertEq(clonable.developer(), developer);
        assertEq(clonableZeroDev.developer(), zeroAddress);
    }

    function test_clone() public {
        bytes memory initData;

        Clonable clone = Clonable(
            clonable.clone(address(this), initData));
        assertEq(clone.developer(), developer);
    }

    event Cloned(address cloneContract, address indexed forClient);

    function test_cloneEmit() public {
        bytes memory initData;

        vm.expectEmit(true, true, true, false, address(clonable));
        emit Cloned(address(0), address(this));
        clonable.clone(address(this), initData);
    }

    function test_cloneZeroDev() public {
        bytes memory initData;

        Clonable clone = Clonable(
            clonableZeroDev.clone(address(this), initData));
        assertEq(clone.developer(), zeroAddress);
    }

    function test_cloneNotMother() public {
        bytes memory initData;

        Clonable clone = Clonable(
            clonable.clone(address(this), initData));
        vm.expectRevert(Clonable.NotMotherContract.selector);
        clone.clone(address(this), initData);
    }

    function test_cloneCloneAlreadyInitialized() public {
        bytes memory initData;

        Clonable clone = Clonable(
            clonable.clone(address(this), initData));
        vm.expectRevert(Clonable.CloneAlreadyInitialized.selector);
        clone.initClone(address(this), address(clonable), initData);
    }

    function test_cloneWrongInitData() public {
        bytes memory initData = abi.encodePacked("wrong data");

        vm.expectRevert(Clonable.WrongInitData.selector);
        clonable.clone(address(this), initData);
    }

}
