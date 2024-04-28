// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/VaultShop.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockVault.sol";

contract MockDeploy is Script {
    address payable zeroAddress = payable(address(0));
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        VaultShop shop = new VaultShop();
        console.log('shop', address(shop));

        uint amount = 1000000 * 10**18;
        IERC20 asset0 = new MockERC20("MockAsset0", "MA0", amount);
        IERC20 asset1 = new MockERC20("MockAsset1", "MA1", amount);
        IERC20 asset2 = new MockERC20("MockAsset2", "MA2", amount);
        console.log('asset0', address(asset0));
        console.log('asset1', address(asset1));
        console.log('asset2', address(asset2));

        MockVault vault0 = new MockVault(address(shop), "MockVault0", "MV0", asset0);
        MockVault vault1 = new MockVault(address(shop), "MockVault1", "MV1", asset1);
        MockVault vault2 = new MockVault(address(shop), "MockVault2", "MV2", asset2);
        console.log('vault0', address(vault0));
        console.log('vault1', address(vault1));
        console.log('vault2', address(vault2));
//        vault0.transferOwnership(address(shop));
//        vault1.transferOwnership(address(shop));
//        vault2.transferOwnership(address(shop));

        shop.produce(vault0, '', zeroAddress);
        shop.produce(vault1, '', zeroAddress);

        shop.setFee(250 * 10**18);

        vm.stopBroadcast();
    }
}
