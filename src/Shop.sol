// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IClonable.sol";
import "./oz/access/Ownable.sol";

// @title Shop Contract
// @notice Produces contract by specified factory
contract Shop is Ownable {
    uint fee;
    mapping (address => address[]) public userContracts;

    event Produced(address indexed source, address clone, address indexed user, address indexed affiliate, uint feePaid);
    event FeeChanged(uint fee);

    error WrongValue();

    constructor(uint fee_) Ownable() {
        setFee(fee_);
    }

    function setFee(uint fee_)
    onlyOwner public {
        fee = fee_;
        emit FeeChanged(fee_);
    }

    function getAllUserContracts(address user)
    external view returns (address[] memory) {
        return userContracts[user];
    }

    function produce(IClonable clonable, address payable affiliate)
    external payable returns (address clonedContract) {
        if (msg.value != fee) revert WrongValue();
        // transfer 50% to the affiliate
        if (affiliate != address(0)) affiliate.transfer(msg.value / 2);
        // transfer the rest to the owner
        payable(owner()).transfer(address(this).balance);

        address user = msg.sender;
        clonedContract = clonable.clone(user);
        // push deployed contract address to the storage
        userContracts[user].push(clonedContract);
        emit Produced(address(clonable), clonedContract, user, affiliate, msg.value);
    }
}
