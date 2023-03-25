// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../oz/access/Ownable.sol";
import "../oz/proxy/Clones.sol";
import "../interfaces/IClonable.sol";

// @title Base Clonable Contract
// @author G1orian
contract Clonable is IClonable, Ownable {

    bool private motherContract; // it will be false at cloned contracts

    event Cloned(address cloneContract, address indexed forClient);

    error CloneAlreadyInitialized();
    error NotMotherContract();
    error WrongInitData();

    constructor() Ownable() {
        motherContract = true;
    }

    function clone(address cloneOwner, bytes memory initData)
    onlyOwner external override returns (address newClone) {
        if (!motherContract) revert NotMotherContract();
        newClone = Clones.clone(address(this));
        IClonable(newClone).initClone(cloneOwner, initData);
        emit Cloned(newClone, cloneOwner);
    }

    /**
     * @dev Initializes fresh clone with
     */
    function initClone(address cloneOwner, bytes memory initData)
    external override virtual {
        if (owner() != address(0)) revert CloneAlreadyInitialized();
        _transferOwnership(cloneOwner);
        _initCloneWithData(initData);
    }

    /**
     * @dev Override this function to init clone this specific data
     */
    function _initCloneWithData(bytes memory initData)
    internal virtual {
        if (initData.length != 0) revert WrongInitData();
    }

}