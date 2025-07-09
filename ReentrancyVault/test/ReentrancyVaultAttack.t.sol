// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ReentrancyVault.sol";
import "../src/ReentrancyAttack.sol";

/// @title ReentrancyVaultAttackTest
/// @notice Tests the reentrancy exploit on the vulnerable ReentrancyVault contract
contract ReentrancyVaultAttackTest is Test {
    ReentrancyVault public vault;
    ReentrancyAttack public attacker;

    address public owner;
    address public attackerEOA;

    function setUp() public {
        owner = makeAddr("owner");
        attackerEOA = makeAddr("attacker");

        vm.deal(owner, 3 ether);
        vm.deal(attackerEOA, 1 ether);

        vm.prank(owner);
        vault = new ReentrancyVault();

        vm.prank(attackerEOA);
        attacker = new ReentrancyAttack(address(vault));

        // The owner deposits 3 ETH into the vault to simulate a realistic scenario
        // where the vault holds user funds. This makes the attack meaningful,
        // as the attacker will try to drain these funds using reentrancy.
        vm.prank(owner);
        vault.deposit{value: 3 ether}();
    }

    function testReentrancyExploit() public {
        // Attacker initiates the exploit with 1 ETH
        vm.prank(attackerEOA);
        attacker.attack{value: 1 ether}();

        uint256 vaultBalance = address(vault).balance;
        uint256 attackerBalance = address(attacker).balance;

        emit log_named_uint("Vault balance after attack", vaultBalance);
        emit log_named_uint("Attacker contract balance", attackerBalance);

        assertLe(vaultBalance, 1 ether);        // Vault should be drained
        assertGe(attackerBalance, 3 ether);     // Attacker stole funds
    }
}
