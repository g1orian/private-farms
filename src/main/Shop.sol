// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IClonable.sol";
import "../openzeppelin/access/Ownable.sol";

// @dev Cloning Shop Contract
// @author G1orian
contract Shop is Ownable {
    // @dev fee for cloning
    uint public fee;
    // @dev user => contracts
    mapping (address => address[]) public userContracts;
    // @dev user => affiliate
    mapping (address => address payable) public userAffiliates;

    event Produced(address indexed source, address clone, address indexed user, address indexed affiliate, uint feePaid);
    event FeeChanged(uint fee);

    error WrongValue();

    /**
     * @dev Constructor
     * @param fee_ fee for cloning
     */
    constructor(uint fee_) Ownable() {
        setFee(fee_);
    }

    /**
     * @dev Set fee for cloning
     */
    function setFee(uint fee_)
    onlyOwner public {
        fee = fee_;
        emit FeeChanged(fee_);
    }

    /**
     * @dev Transfer ownership of the contract to the owner of the shop
     */
    function returnOwnership(address contractAddress)
    onlyOwner public {
        Ownable(contractAddress).transferOwnership(msg.sender);
    }

    /**
     * @dev Get all contracts deployed by the user
     */
    function getAllUserContracts(address user)
    external view returns (address[] memory) {
        return userContracts[user];
    }

    /**
     * @dev Deploy new clone contract
     * @param clonable address of the contract to clone
     * @param initData data to init new contract
     */
    function produce(IClonable clonable, bytes memory initData, address payable affiliate)
    external payable returns (address clonedContract) {
        if (msg.value != fee) revert WrongValue();

        // transfer 50% to the the affiliate
        address payable userAffiliate = userAffiliates[msg.sender];
        // if affiliate is set for the user, override affiliate parameter, to use first set affiliate
        if (userAffiliate != address(0)) affiliate = userAffiliate;
        if (affiliate != address(0)) {
            // store affiliate for the user's next transactions
            userAffiliates[msg.sender] = affiliate;
            affiliate.transfer(msg.value / 2);
        }

        // transfer 50% of the balance to the the contract developer
        address payable developer = clonable.developer();
        if (developer != address(0)) {
            developer.transfer(address(this).balance / 2);
        }

        // transfer the rest to the owner
        payable(owner()).transfer(address(this).balance);

        address user = msg.sender;
        clonedContract = clonable.clone(user, initData);
        // push deployed contract address to the storage
        userContracts[user].push(clonedContract);
        emit Produced(address(clonable), clonedContract, user, affiliate, msg.value);
    }
}
