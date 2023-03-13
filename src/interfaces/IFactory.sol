// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFactory {
    function deploy(address client, bytes memory data)
    external returns (address deployedContract);
}
