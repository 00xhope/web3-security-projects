# 🔐 Security Review: ReentrancyVault

## Summary

This report analyzes a deliberately vulnerable smart contract (`ReentrancyVault`) affected by a classic Reentrancy vulnerability (SWC-107). The goal is to demonstrate the risk, exploit path, and secure mitigation strategy using an end-to-end approach.

---

## Vulnerability Details

- **Type:** Reentrancy  
- **SWC-ID:** SWC-107  
- **Location:** `withdraw()` function  
- **Severity:** High  
- **Exploitability:** External contract-controlled fallback

### Root Cause

The `withdraw()` function sends ETH to `msg.sender` before updating their balance. This allows an attacker to re-enter the function multiple times during the same call and drain funds beyond their balance.

### Vulnerable Code

```solidity
(bool success, ) = msg.sender.call{value: amount}("");
require(success, "Transfer failed");
balances[msg.sender] = 0;
```

- Balance update comes after the external call
- Attacker can recursively re-enter `withdraw()` via fallback

---

## Exploitation Steps

1. Attacker deposits 1 ETH  
2. Attacker deploys a malicious contract with a fallback that re-enters `withdraw()`  
3. The recursive call repeats until the vault's balance is drained

### Attack PoC

- Exploit contract: `ReentrancyAttack.sol`  
- Attack script: `Attack.s.sol`  
- Foundry test: `ReentrancyVaultAttack.t.sol`

---

## Fix & Mitigation

### Fixed Code

```solidity
balances[msg.sender] = 0;
(bool success, ) = msg.sender.call{value: amount}("");
require(success, "Transfer failed");
```

- The user's balance is now cleared before sending ETH  
- This breaks the reentrancy loop by ensuring state change happens first

### Defense Strategy

- Apply the Check-Effects-Interactions pattern  
- Consider using OpenZeppelin’s `ReentrancyGuard` for additional safety

---

## Lessons Learned

- Always update internal state before making external calls  
- Be cautious when using `.call()` with `msg.sender`  
- Simulate attacks in tests using malicious fallback contracts

---

## References

- [SWC-107: Reentrancy](https://swcregistry.io/docs/SWC-107)  
- [Ethernaut - Reentrancy Level](https://ethernaut.openzeppelin.com/level/0xB2c5f7DaD94b2A4f7d7cA6c1C4f35b2a17f49b2f)  
- [OpenZeppelin - Security Patterns](https://docs.openzeppelin.com/contracts/4.x/security)

---

> Reviewed and documented by [00xhope](https://x.com/00xhope)