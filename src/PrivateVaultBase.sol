// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import "./Cloneable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// @title Base Private Vault Contract
// @author Bogdoslav
abstract contract PrivateVaultBase is Cloneable, ERC4626 {
    using SafeERC20 for IERC20;

    // @dev who can call doWork()
    address public worker;

    // @dev last time doWork() was called. Used to calc APR and APY
    uint public lastHarvest;

    // @dev previous (before last) time doWork() was called. Used to calc APR and APY
    uint public prevHarvest;

    // @dev last profit (in asset) from doWork(). Used to calc APR and APY
    uint public lastProfit;

    event WorkerChanged(address worker);
    event Harvest(uint profit, uint totalAssetsAfter);

    error NoProfitableWork();
    error NotOwnerOrWorker();

    // @notice All arguments are used to initialize the contract must be immutable to support cloning (proxy pattern)
    constructor(address owner_, IERC20 asset_)
    ERC20('', '') // We are overriding name() and symbol() virtual functions
    ERC4626(asset_)
    Cloneable(owner_)
    {
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override (ERC20, IERC20Metadata) returns (string memory) {
        return 'PrivateVaultBase';
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override (ERC20, IERC20Metadata) returns (string memory) {
        return 'PVB';
    }

//    function _initCloneWithData(address source, bytes memory initData)
//    internal override virtual {
//    }

    // ******** ONLY OWNER *********

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

    function redeemAll(address receiver, address owner)
    onlyOwner public returns (uint assets) {
        uint shares = balanceOf(owner);
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
        if (amount == 0) {
            amount = address(this).balance;
        }
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
        if (amount == 0) {
            amount = IERC20(token).balanceOf(address(this));
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    // ******** RECEIVE *********

    receive() external payable {}

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

    /**
     * @dev Calculates APR based on last profit and time since prev to last hard work
     * @return APR with 18 decimals
     */
    function APR() public view returns (uint) {
        uint _prevHarvest = prevHarvest;
        uint _lastHarvest = lastHarvest;
        uint _lastProfit = lastProfit;

        if (_prevHarvest == 0 || _lastHarvest == 0 || _lastProfit == 0) return 0;

        uint period = _lastHarvest - _prevHarvest;
        uint yearlyProfit = _lastProfit * 365 days / period;
        return yearlyProfit * 10**18 / totalAssets();
    }

    // ******** HARD WORK *********

    function doWork()
    external virtual {
        uint totalBefore = totalAssets();

        _doWork();

        uint totalAfter = totalAssets();
        // Revert on loss to prevent loss of funds
        if (totalAfter < totalBefore) revert('Loss');

        uint profit = totalAfter - totalBefore;

        lastProfit = profit;
        prevHarvest = lastHarvest;
        lastHarvest = block.timestamp;

        emit Harvest(profit, totalAfter);
    }

    // *******************************
    // ******** TO IMPLEMENT *********
    // *******************************

    /**
     * @dev Do Hard Work common workflow
     * @notice Must revert with NoProfitableWork() when there is no work to do to avoid transaction cost (as Gelato simulates tx before actual run)
     */
    function _doWork() internal virtual {
        // claim rewards (if any)
        _claimRewardsAndConvertToAsset();
        // invest free assets
        uint freeAssets = _freeAssets();
        if (freeAssets > 0) {
            _invest(_freeAssets());
        } else {
            // revert to avoid transaction cost
            revert NoProfitableWork();
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

    /**
     * @dev Gelato automation checker function. Gelato can be configured to call doWork()
     *  when this function returns true. It can be used for re-balancing,
     *  for example or when you need to call doWork depending your logic,
     *  and not just every N hours.
     * @notice https://docs.gelato.network/developer-services/automate/guides/custom-logic-triggers/smart-contract-resolvers
     * @return canExec can be doWork() executed right now?
     * @return execPayload - should be empty for usual doWork call
     */
    function canHarvest() external view virtual
    returns (bool canExec, bytes memory execPayload)
    {
        canExec = false;
        execPayload = '';
    }


}
