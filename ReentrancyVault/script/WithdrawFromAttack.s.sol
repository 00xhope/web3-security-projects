// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface IAttack {
    function withdrawFunds() external;
}

/// @title WithdrawFromAttack
/// @notice Withdraws ETH from the ReentrancyAttack contract to the attacker's wallet
contract WithdrawFromAttack is Script {
    function run() external {
        address attackContract = vm.envAddress("ATTACK_CONTRACT_ADDRESS");

        vm.startBroadcast();
        IAttack(attackContract).withdrawFunds();
        vm.stopBroadcast();
    }
}
