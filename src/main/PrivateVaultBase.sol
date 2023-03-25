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
// @author G1orian
abstract contract PrivateVaultBase is Clonable, ERC4626 {
    using SafeERC20 for IERC20;

    // @dev who can call doHardWork()
    address public worker;

    event WorkerChanged(address worker);

    error NotWorker();

    constructor(IERC20 asset_) ERC4626(asset_) {
    }

    modifier onlyWorkerOrOwner() {
        if (worker != msg.sender || owner() != msg.sender) revert NotWorker();
        _;
    }

    function _initCloneWithData(bytes memory initData)
    internal override virtual {
        address worker_ = abi.decode(initData, (address));
        setWorker(worker_);
    }

    // ******** ONLY OWNER *********

    function setWorker(address worker_)
    onlyOwner public {
        worker = worker_;
        emit WorkerChanged(worker_);
    }

    function deposit(uint assets, address receiver)
    onlyOwner public override returns (uint shares) {
        return super.deposit(assets, receiver);
    }

    function mint(uint shares, address receiver)
    onlyOwner public override returns (uint assets) {
        return super.mint(shares, receiver);
    }

    function withdraw(uint assets, address receiver, address owner)
    onlyOwner public override returns (uint shares) {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(uint shares, address receiver, address owner)
    onlyOwner public override returns (uint assets) {
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

    // ******** DEPOSIT / WITHDRAW ********

    function _freeAssets()
    internal virtual returns (uint) {
        return ERC20(asset()).balanceOf(address(this));
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint assets, uint shares)
    internal override virtual {
        super._deposit(caller, receiver, assets, shares);
        // invest all available assets
        _invest(_freeAssets());
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(address caller, address receiver, address owner, uint assets, uint shares)
    internal override virtual {
        // un stake needed assets amount
        _devest(assets - _freeAssets());
        super._withdraw(caller, receiver, owner, assets, shares);
    }

    function totalAssets() public view virtual override returns (uint) {
        return IERC20(asset()).balanceOf(address(this)) + investedAssets();
    }

    // ******** TO IMPLEMENT *********

    /**
     * @dev Should return how much assets invested / staked
     */
    function investedAssets() public view virtual returns (uint);

    /**
     * @dev Should invest / stake free assets from the vault
     */
    function _invest(uint assets) internal virtual;

    /**
     * @dev Should de-vest / un-stake assets from the underlying protocol to the vault
     *    - if available amount less then requested, then do not revert and withdraw all available
     */
    function _devest(uint assets) internal virtual;

    /**
     * @dev Should claim all rewards
     */
    function _claimRewards() internal virtual;

    /**
     * @dev Should convert rewards to asset
     *    - check and skip conversion when no rewards
     */
    function _convertRewardsToAsset() internal virtual;

    /**
     * @dev Do Hard Work common workflow
     */
    function _doHardWork() internal virtual {
        // claim rewards (if any)
        _claimRewards();
        // convert rewards to asset
        _convertRewardsToAsset();
        // invest free assets
        uint freeAssets = _freeAssets();
        if (freeAssets > 0) {
            _invest(_freeAssets());
        }

    }




}
