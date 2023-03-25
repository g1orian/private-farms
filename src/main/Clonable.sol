// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../oz/access/Ownable.sol";
import "../oz/proxy/Clones.sol";
import "../interfaces/IClonable.sol";

// @title Base Clonable Contract
contract Clonable is IClonable, Ownable {

    bool private motherContract; // it will be false at cloned contracts

    event Cloned(address cloneContract, address indexed forClient);

    error CloneAlreadyInitialized();
    error NotMotherContract();

    constructor() Ownable() {
        motherContract = true;
    }

    function clone(address client)
    onlyOwner external override returns (address newClone) {
        if (!motherContract) revert NotMotherContract();
        newClone = Clones.clone(address(this));
        IClonable(newClone).initClone(client);
        emit Cloned(newClone, client);
    }

    function initClone(address client)
    external override virtual {
        if (owner() != address(0)) revert CloneAlreadyInitialized();
        _transferOwnership(client);
    }

}