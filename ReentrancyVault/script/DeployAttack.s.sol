// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ReentrancyAttack.sol"; // dosya yolunu kendi yapına göre ayarla

/// @title DeployAttack
/// @notice Deploys the ReentrancyAttack contract pointing to the Vault
contract DeployAttack is Script {
    function run() external {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");

        vm.startBroadcast();
        new ReentrancyAttack(vaultAddress);
        vm.stopBroadcast();
    }
}
