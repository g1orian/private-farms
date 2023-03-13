// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @title Factory Contract
// @notice Deploys proxy for specified implementation contract
contract Factory {
    address payable owner;
    uint fee;

    error AlreadyInitialized();
    error ZeroParameter();

    function initialize(address owner_, uint fee_)
    external {
        if (owner != address(0)) revert AlreadyInitialized();
        if (owner_ == address(0)) revert ZeroParameter();
        owner = payable(owner_);
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
