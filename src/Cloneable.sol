// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./interfaces/ICloneable.sol";

// @title Base Cloneable Contract
// @author Bogdoslav
contract Cloneable is ICloneable {

    /// @dev true if this is source (not cloned) contract
    bool private sourceContract; // it will be false at cloned contracts
    address public owner;

    event Cloned(address cloneContract, address indexed forClient);

    error AlreadyInitialized();
    error NotSourceContract();
    error WrongInitData();
    error NotOwner();

    /**
     * @dev Constructor
     */
    constructor(address owner_) {
        sourceContract = true;
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /**
     * @dev Clone source contract
     * @param cloneOwner address of the new contract owner
     * @param initData data to init new contract
     */
    function clone(address cloneOwner, bytes memory initData)
    onlyOwner external override returns (address newClone) {
        // Prevent cloning clones
        if (!sourceContract) revert NotSourceContract();

        newClone = Clones.clone(address(this));
        ICloneable(newClone).initClone(cloneOwner, address(this), initData);
        emit Cloned(newClone, cloneOwner);
    }

    /**
     * @dev Initializes fresh clone with specific data
     * @param cloneOwner address of the new contract owner
     * @param initData data to init new contract
     */
    function initClone(address cloneOwner, address source, bytes memory initData)
    external override virtual {
        if (owner != address(0)) revert AlreadyInitialized();

        owner = cloneOwner;
        _initCloneWithData(source, initData);
    }

    /**
     * @dev Override this function to init clone with specific data
     * @param initData data to init new contract
     */
    function _initCloneWithData(address /*source*/, bytes memory initData)
    internal virtual {
        if (initData.length != 0) {
            revert WrongInitData();
        }
    }

}
