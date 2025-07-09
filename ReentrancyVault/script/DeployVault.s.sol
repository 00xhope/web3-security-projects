// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ReentrancyVault.sol";

contract DeployVault is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        ReentrancyVault vault = new ReentrancyVault();
        console2.log("Vulnerable vault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}
