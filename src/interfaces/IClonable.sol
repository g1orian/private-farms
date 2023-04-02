// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author G1orian
interface IClonable {
    // @dev address of the contract developer (to share revenue)
    function developer() external returns (address payable);
    // @dev called on mother contract
    function clone(address client, bytes memory initData) external returns (address newClone);
    // @dev called on cloned contract
    function initClone(address client, bytes memory initData) external;
}
