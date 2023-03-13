// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// @title Proxies Factory Contract
// @notice Deploys proxy for specified implementation contract
contract ProxiesFactory {
    address payable owner;
    uint fee;

    error AlreadyInitialized();

    function initialize(uint fee_)
    external {
        if (owner != address(0)) revert AlreadyInitialized();
        owner = payable(msg.sender);
        fee = fee_;
        // TODO
    }

    function produce(address sourceContract, bytes memory initData, address payable affiliate)
    external payable returns (address deployedContract) {
        // TODO check and transfer fees
        // TODO check sourceContract is contract
        // TODO check sourceContract is not proxy already
        // TODO deploy proxy
        deployedContract = address(0); // TODO
        // TODO init proxy
        // TODO call initData
    }
}
