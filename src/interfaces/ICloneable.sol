// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// TODO update
// @author Bogdoslav
interface ICloneable {
    /**
     * @notice call on source contract
     * @param client address of the new contract owner
     * @param initData data to init new contract
     */
    function clone(address client, bytes memory initData) external returns (address newClone);

    /**
     * @notice call on cloned contract
     * @param client address of the new contract owner
     * @param initData data to init new contract
     */
    function initClone(address client, address source, bytes memory initData) external;
}
