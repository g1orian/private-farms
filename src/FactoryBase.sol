// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IFactory.sol";

// @title Base Factory Contract
abstract contract FactoryBase is IFactory {
    address owner;

    error AlreadyInitialized();
    error ZeroParameter();
    error NotOwner();

    // TODO add events

    modifier onlyOwner() {
        if (msg.sender != owner)
            revert NotOwner();
        else _;
    }

    function initialize(address owner_, uint fee_)
    external {
        if (owner != address(0)) revert AlreadyInitialized();
        if (owner_ == address(0)) revert ZeroParameter();
        owner = payable(owner_);
    }

    function deploy(address client, bytes memory data)
    onlyOwner external returns (address deployedContract) {
        deployedContract = _deploy(client, data);
    }

    // TO IMPLEMENT

    function _deploy(address client, bytes memory data)
    internal virtual returns (address deployedContract);

}
