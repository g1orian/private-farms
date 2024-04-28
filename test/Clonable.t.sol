// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Cloneable.sol";

// @dev Tests for Cloneable Contract
contract CloneableTest is Test {
    Cloneable public cloneable;
    Cloneable public cloneableZeroDev;
    address payable public zeroAddress = payable(address(0));

    function setUp() public {
        cloneable = new Cloneable(address(this));
    }

    function test_clone() public {
        Cloneable clone = Cloneable(
            cloneable.clone(address(this), ''));
        // TODO
    }

    event Cloned(address cloneContract, address indexed forClient);

    function test_cloneEmit() public {
        bytes memory initData;

        vm.expectEmit(true, true, true, false, address(cloneable));
        emit Cloned(address(0), address(this));
        cloneable.clone(address(this), initData);
    }

    function test_cloneNotMother() public {
        bytes memory initData;

        Cloneable clone = Cloneable(
            cloneable.clone(address(this), initData));
        vm.expectRevert(Cloneable.NotSourceContract.selector);
        clone.clone(address(this), initData);
    }

    function test_cloneCloneAlreadyInitialized() public {
        bytes memory initData;

        Cloneable clone = Cloneable(
            cloneable.clone(address(this), initData));
        vm.expectRevert(Cloneable.AlreadyInitialized.selector);
        clone.initClone(address(this), address(cloneable), initData);
    }

    function test_cloneWrongInitData() public {
        bytes memory initData = abi.encodePacked("wrong data");

        vm.expectRevert(Cloneable.WrongInitData.selector);
        cloneable.clone(address(this), initData);
    }

}
