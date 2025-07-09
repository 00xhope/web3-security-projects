// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ReentrancyVaultFixed.sol";

contract DeployVaultFixed is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        ReentrancyVaultFixed vault = new ReentrancyVaultFixed();
        console2.log("Secure vault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}
