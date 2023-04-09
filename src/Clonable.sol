// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./interfaces/IClonable.sol";

// @title Base Clonable Contract
// @author G1orian
contract Clonable is IClonable, Ownable {

    /// @dev true if this is mother (not cloned) contract
    bool private motherContract; // it will be false at cloned contracts
    /// @dev address of the contract developer (to share revenue)
    address payable public immutable override developer;

    event Cloned(address cloneContract, address indexed forClient);

    error CloneAlreadyInitialized();
    error NotMotherContract();
    error WrongInitData();

    /**
     * @dev Constructor
     * @param developer_ address of the contract developer (to share revenue)
     */
    constructor(address payable developer_) Ownable() {
        motherContract = true;
        developer = developer_;
    }

    /**
     * @dev Clone mother contract
     * @param cloneOwner address of the new contract owner
     * @param initData data to init new contract
     */
    function clone(address cloneOwner, bytes memory initData)
    onlyOwner external override returns (address newClone) {
        if (!motherContract) {
            revert NotMotherContract();
        }
        newClone = Clones.clone(address(this));
        IClonable(newClone).initClone(cloneOwner, initData);
        emit Cloned(newClone, cloneOwner);
    }

    /**
     * @dev Initializes fresh clone with specific data
     * @param cloneOwner address of the new contract owner
     * @param initData data to init new contract
     */
    function initClone(address cloneOwner, bytes memory initData)
    external override virtual {
        if (owner() != address(0)) {
            revert CloneAlreadyInitialized();
        }
        _transferOwnership(cloneOwner);
        _initCloneWithData(initData);
    }

    /**
     * @dev Override this function to init clone with specific data
     * @param initData data to init new contract
     */
    function _initCloneWithData(bytes memory initData)
    internal virtual {
        if (initData.length != 0) {
            revert WrongInitData();
        }
    }

}