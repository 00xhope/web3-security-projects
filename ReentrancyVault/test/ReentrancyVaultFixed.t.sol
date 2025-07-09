// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ReentrancyVaultFixed.sol";
import "../src/ReentrancyAttack.sol";

/// @title ReentrancyVaultFixedTest
/// @notice Verifies that the fixed version of the vault is not vulnerable to reentrancy attacks
contract ReentrancyVaultFixedTest is Test {
    ReentrancyVaultFixed public vault;
    ReentrancyAttack public attacker;

    address public owner;
    address public attackerEOA;

    function setUp() public {
        owner = makeAddr("owner");
        attackerEOA = makeAddr("attacker");

        vm.deal(owner, 3 ether);
        vm.deal(attackerEOA, 1 ether);

        vm.prank(owner);
        vault = new ReentrancyVaultFixed();

        vm.prank(attackerEOA);
        attacker = new ReentrancyAttack(address(vault));

        // The owner deposits 3 ETH into the vault to simulate real user funds.
        // The attacker will attempt to exploit the vault, but the fixed version
        // should prevent reentrancy and preserve the full balance.
        vm.prank(owner);
        vault.deposit{value: 3 ether}();
    }

    function testAttackShouldFail() public {
        vm.prank(attackerEOA);
        attacker.attack{value: 1 ether}();

        uint256 vaultBalance = address(vault).balance;
        uint256 attackerBalance = address(attacker).balance;

        emit log_named_uint("Vault balance after failed attack", vaultBalance);
        emit log_named_uint("Attacker contract balance", attackerBalance);

        assertGe(vaultBalance, 2 ether);        // Most of the funds should remain
        assertLe(attackerBalance, 1 ether);     // Attacker should not gain extra ETH
    }
}
