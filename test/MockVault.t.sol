// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/mocks/MockVault.sol";
import "../src/mocks/MockERC20.sol";

// @dev Tests for MockVault (PrivateVaultBase) Contract
contract MockVaultTest is Test {
    MockVault public vault;
    string name = "MockVault";
    string symbol = "MV";
    IERC20 asset = new MockERC20("MockAsset", "MA", 10**(18+9));

    address payable public developer = payable(makeAddr("developer"));
    address payable public zeroAddress = payable(address(0));
    address public worker = makeAddr("worker");

    event WorkerChanged(address worker);

    function setUp() public {
        vault = new MockVault(name, symbol, asset, developer);
        vault.setWorker(worker);

    }

    function test_setWorker() public {
        assertEq(vault.worker(), worker);

        address newWorker = makeAddr("newWorker");

        vm.expectEmit(true, true, true, true, address(vault));
        emit WorkerChanged(newWorker);
        vault.setWorker(newWorker);
        assertEq(vault.worker(), newWorker);
    }

}
