// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface IVault {
    function deposit() external payable;
}

/// @title DepositToVault
/// @notice Deposits 3 ETH into the Vault contract
contract DepositToVault is Script {
    function run() external {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");

        vm.startBroadcast();
        IVault(vaultAddress).deposit{value: 3 ether}();
        vm.stopBroadcast();
    }
}
