// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IClonable {
    function clone(address client) external returns (address newClone);
    function initClone(address client) external;
}
