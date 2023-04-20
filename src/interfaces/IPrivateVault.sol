// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// TODO remove file
// @title Private Vault Interface
// @author Bogdoslav
interface IPrivateVault {

    // @dev who can call doHardWork()
    function worker() external view returns (address);
    function owner() external view returns (address);
    function asset() external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function prevHardWork() external view returns (uint);
    function lastHardWork() external view returns (uint);
    function lastProfit() external view returns (uint);

    event WorkerChanged(address worker);
    error NotWorkerOrOwner();

    // ******** ONLY OWNER *********

    function setWorker(address worker_) external;

    function deposit(uint assets, address receiver)
    external returns (uint shares);

    function mint(uint shares, address receiver)
    external returns (uint assets);

    function withdraw(uint assets, address receiver, address owner)
    external returns (uint shares);

    function redeem(uint shares, address receiver, address owner)
    external returns (uint assets);

    // ******** ONLY WORKER OR OWNER *********

    function doHardWork() external;

    // ******** SALVAGE *********

    /**
     * @dev Salvage network token from this contract.
     * @param amount amount of the token to salvage
     *  - when 0, will salvage all tokens
     */
    function salvage(uint amount) external;

    /**
     * @dev Salvage any ERC20 token from this contract.
     * @param token address of the token to salvage
     * @param amount amount of the token to salvage
     *  - when 0, will salvage all tokens
     */
    function salvageERC20(address token, uint amount) external;

    /**
     * @dev Salvage any ERC721 token from this contract.
     * @param token address of the token to salvage
     * @param tokenId id of the token to salvage
     */
    function salvageERC721(address token, uint tokenId) external;

    // ******** ASSETS ********

    /**
     * @dev Should return total assets (free + invested)
     */
    function totalAssets() external view returns (uint);

    /**
     * @dev Should return how much assets invested / staked
     *    - used to calculate total assets
     */
    function investedAssets() external view returns (uint);

    function APR() external view returns (uint);


}
