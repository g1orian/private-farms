// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IFactory.sol";
import "./oz/access/Ownable.sol";

// @title Base Factory Contract
abstract contract FactoryBase is IFactory, Ownable {

    event Deployed(address client);

    constructor () Ownable() {
    }

    function deploy(address client, bytes memory data)
    onlyOwner external returns (address deployedContract) {
        deployedContract = _deploy(client, data);
        emit Deployed(client);
    }

    /**
     * @dev Implement this function for specific factory.
     */
    function _deploy(address client, bytes memory data)
    internal virtual returns (address deployedContract);

}
