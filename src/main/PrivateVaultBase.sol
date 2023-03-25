// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../oz/token/ERC20/extensions/ERC4626.sol";
import "../oz/access/Ownable.sol";
import "../oz/proxy/Clones.sol";
import "../oz/token/ERC20/utils/SafeERC20.sol";
import "../oz/token/ERC721/IERC721.sol";
import "./Clonable.sol";

// @title Base Private Vault Contract
// @notice initialize() used instead of constructor to work with proxy pattern
abstract contract PrivateVaultBase is Clonable, ERC4626 {
    using SafeERC20 for IERC20;

    address public worker;

    event WorkerChanged(address worker);

    constructor(IERC20 asset_) ERC4626(asset_) {
    }

    modifier onlyWorkerOrOwner() {
        require(worker == msg.sender || owner() == msg.sender, "PrivateVault: not worker or owner");
        _;
    }

    function setWorker(address worker_)
    onlyOwner external {
        worker = worker_;
        emit WorkerChanged(worker_);
    }

    function deposit(uint256 assets, address receiver)
    onlyOwner public override returns (uint256 shares) {
        return super.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver)
    onlyOwner public override returns (uint256 assets) {
        return super.mint(shares, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner)
    onlyOwner public override returns (uint256 shares) {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
    onlyOwner public override returns (uint256 assets) {
        return super.redeem(shares, receiver, owner);
    }

    function doHardWork()
    onlyWorkerOrOwner external {
        _doHardWork();
    }

    // ******** SALVAGE *********

    function salvage(uint amount)
    onlyOwner external {
        if (amount == 0) amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function salvageERC20(address token, uint amount)
    onlyOwner external {
        if (amount == 0) amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function salvageERC721(address token, uint tokenId)
    onlyOwner external {
        IERC721(token).transferFrom(address(this), msg.sender, tokenId);
    }

    // ******** HARD WORK *********

    function _doHardWork() internal virtual;

}
