// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import "./Clonable.sol";

// @title Base Private Vault Contract
// @author Bogdoslav
abstract contract PrivateVaultBase is Clonable, ERC4626 {
    using SafeERC20 for IERC20;

    // @dev who can call doHardWork()
    address public worker;

    // @dev last time doHardWork() was called. Used to calc APR and APY
    uint lastHardWork;

    // @dev previous (before last) time doHardWork() was called. Used to calc APR and APY
    uint prevHardWork;

    // @dev last profit (in asset) from doHardWork()
    uint lastProfit;

    event WorkerChanged(address worker);
    event HardWork(uint profit, uint totalAssetsAfter);

    error NotWorkerOrOwner();
    error NoWork();
    error Loss();

    // @notice All arguments are used to initialize the contract must be immutable to support cloning (proxy pattern)
    constructor(string memory name_, string memory symbol_, IERC20 asset_, address payable developer_)
    ERC20(name_, symbol_)
    ERC4626(asset_)
    Clonable(developer_)
    {
    }

    modifier onlyWorkerOrOwner() {
        if (worker != msg.sender && owner() != msg.sender) revert NotWorkerOrOwner();
        _;
    }

    function _initCloneWithData(bytes memory initData)
    internal override virtual {
        // skip initialization if no data provided, as worker can be set later
        if (initData.length == 0)
            return;
        address worker_ = abi.decode(initData, (address));
        _setWorker(worker_);
    }

    function _setWorker(address worker_)
    internal {
        worker = worker_;
        emit WorkerChanged(worker_);
    }

    // ******** ONLY OWNER *********

    function setWorker(address worker_)
    onlyOwner public {
        _setWorker(worker_);
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

    // ******** SALVAGE *********

    /**
     * @dev Salvage network token from this contract.
     * @param amount amount of the token to salvage
     *  - when 0, will salvage all tokens
     */
    function salvage(uint amount)
    onlyOwner external {
        if (amount == 0) amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev Salvage any ERC20 token from this contract.
     * @param token address of the token to salvage
     * @param amount amount of the token to salvage
     *  - when 0, will salvage all tokens
     */
    function salvageERC20(address token, uint amount)
    onlyOwner external {
        if (amount == 0) amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    /**
     * @dev Salvage any ERC721 token from this contract.
     * @param token address of the token to salvage
     * @param tokenId id of the token to salvage
     */
    function salvageERC721(address token, uint tokenId)
    onlyOwner external {
        IERC721(token).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    // ******** RECEIVE *********

    receive() external payable {}

    function onERC721Received(address /*operator*/, address /*from*/, uint256 /*tokenId*/, bytes memory /*data*/)
    external virtual pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // ******** DEPOSIT / WITHDRAW ********

    function _freeAssets()
    internal virtual returns (uint) {
        return ERC20(asset()).balanceOf(address(this));
    }

    /**
     * @dev Deposit/mint common workflow.
     * @param caller who called deposit/mint
     * @param receiver who should receive shares
     * @param assets amount of assets to deposit/mint
     * @param shares amount of shares to mint
     */
    function _deposit(address caller, address receiver, uint assets, uint shares)
    internal override virtual {
        super._deposit(caller, receiver, assets, shares);
        // invest all available assets
        _invest(_freeAssets());
    }

    /**
     * @dev Withdraw/redeem common workflow.\
     * @param caller who called withdraw/redeem
     * @param receiver who should receive assets
     * @param owner who should receive shares
     * @param assets amount of assets to withdraw/redeem
     * @param shares amount of shares to redeem
     */
    function _withdraw(address caller, address receiver, address owner, uint assets, uint shares)
    internal override virtual {
        // un stake needed assets amount
        _divest(assets - _freeAssets());
        super._withdraw(caller, receiver, owner, assets, shares);
    }

    /**
     * @dev Should return total assets (free + invested)
     */
    function totalAssets() public view virtual override returns (uint) {
        return IERC20(asset()).balanceOf(address(this)) + investedAssets();
    }

    // ******** HARD WORK *********

    function doHardWork()
    onlyWorkerOrOwner external {
        uint totalBefore = totalAssets();

        _doHardWork();

        uint totalAfter = totalAssets();
        // Revert on loss to prevent loss of funds
        if (totalAfter < totalBefore) revert Loss();

        uint profit = totalAfter - totalBefore;

        lastProfit = profit;
        prevHardWork = lastHardWork;
        lastHardWork = block.timestamp;

        emit HardWork(profit, totalAfter);
    }

    /**
     * @dev Calculates APR based on last profit and time since prev to last hard work
     * @return APR with 18 decimals
     */
    function APR() public view returns (uint) {
        uint _prevHardWork = prevHardWork;
        uint _lastHardWork = lastHardWork;
        uint _lastProfit = lastProfit;

        if (_prevHardWork == 0 || _lastHardWork == 0 || _lastProfit == 0) return 0;

        uint time = _lastHardWork - _prevHardWork;
        uint yearlyProfit = _lastProfit * 365 days / time;
        return yearlyProfit * 10**18 / totalAssets();
    }

    function APY() public view returns (uint) {
        // TODO https://www.investopedia.com/terms/a/apy.asp
    }

    // *******************************
    // ******** TO IMPLEMENT *********
    // *******************************

    /**
     * @dev Do Hard Work common workflow
     * @notice Must revert with NoWork() when there is no work to do to avoid transaction cost (as Gelato simulates tx before actual run)
     */
    function _doHardWork() internal virtual {
        // claim rewards (if any)
        _claimRewardsAndConvertToAsset();
        // invest free assets
        uint freeAssets = _freeAssets();
        if (freeAssets > 0) {
            _invest(_freeAssets());
        } else {
            // revert to avoid transaction cost
            revert NoWork();
        }

    }

    /**
     * @dev Should return how much assets invested / staked
     *    - used to calculate total assets
     */
    function investedAssets() public view virtual returns (uint);

    /**
     * @dev Should invest / stake free assets from the vault
     * @param assets amount of assets to invest
     */
    function _invest(uint assets) internal virtual;

    /**
     * @dev Should de-vest / un-stake assets from the underlying protocol to the vault
     *    - if available amount less then requested, then do not revert and withdraw all available
     * @param assets amount of assets to de-vest
     */
    function _divest(uint assets) internal virtual;

    /**
     * @dev Should claim all rewards
     * @notice Should convert rewards to asset
     *    - check and skip conversion when no rewards
     */
    function _claimRewardsAndConvertToAsset() internal virtual;


}
