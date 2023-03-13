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
    error WrongMsgValue();

    function initialize(address owner_, uint fee_)
    external {
        if (owner != address(0)) revert AlreadyInitialized();
        if (owner_ == address(0)) revert ZeroParameter();
        owner = payable(owner_);
        fee = fee_;
    }

    function produce(IFactory factory, bytes memory data, address payable affiliate)
    external payable returns (address deployedContract) {
        if (msg.value < fee) revert WrongMsgValue();
        // transfer 50% to the affiliate
        if (affiliate != address(0)) affiliate.transfer(msg.value / 2);
        // transfer the rest to the owner
        owner.transfer(address(this).balance);

        deployedContract = factory.deploy(msg.sender, data);
        // push deployed contract address to the registry
        userContracts[msg.sender].push(deployedContract);
        // TODO emit event

    }
}
