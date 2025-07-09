// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface IVault {
    function withdraw() external;
}

/// @title WithdrawFromVault
/// @notice Withdraws ETH from the Vault contract
contract WithdrawFromVault is Script {
    function run() external {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");

        vm.startBroadcast();
        IVault(vaultAddress).withdraw();
        vm.stopBroadcast();
    }
}
