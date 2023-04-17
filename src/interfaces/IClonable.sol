// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author Bogdoslav
interface IClonable {
    /**
     * @dev address of the contract developer (to share revenue)
     */
    function developer() external returns (address payable);

    /**
     * @notice call on mother contract
     * @param client address of the new contract owner
     * @param initData data to init new contract
     */
    function clone(address client, bytes memory initData) external returns (address newClone);

    /**
     * @notice call on cloned contract
     * @param client address of the new contract owner
     * @param initData data to init new contract
     */
    function initClone(address client, address mother, bytes memory initData) external;
}
