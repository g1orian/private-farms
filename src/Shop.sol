// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IFactory.sol";

// @title Shop Contract
// @notice Produces contract by specified factory
contract Shop {
    address payable owner;
    uint fee;
    mapping (address => address[]) public userContracts;

    // TODO add events

    error AlreadyInitialized();
    error ZeroParameter();

    function initialize(address owner_, uint fee_)
    external {
        if (owner != address(0)) revert AlreadyInitialized();
        if (owner_ == address(0)) revert ZeroParameter();
        owner = payable(owner_);
        fee = fee_;
    }

    function produce(IFactory factory, bytes memory data, address payable affiliate)
    external payable returns (address deployedContract) {
        // TODO check fees
        // TODO transfer fees
        deployedContract = factory.deploy(msg.sender, data);
        // push deployed contract address to the registry
        userContracts[msg.sender].push(deployedContract);

    }
}
