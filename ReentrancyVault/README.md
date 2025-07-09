# ReentrancyVault

This case study demonstrates a classic **Reentrancy** vulnerability in Ethereum smart contracts. It includes the full exploit workflow, fix implementation, and security review.

---

## Overview

A vulnerable vault contract allows users to deposit and withdraw ETH. Due to incorrect state update order (modifying balances after external calls), it is susceptible to a reentrancy attack.

---

## Structure

```
ReentrancyVault/
├── contracts/                       # Smart contracts
│   ├── ReentrancyAttack.sol         # Malicious contract that exploits reentrancy
│   ├── ReentrancyVault.sol          # Vulnerable vault contract
│   └── ReentrancyVaultFixed.sol     # Secure version with reentrancy protection
│
├── script/                          # Foundry scripts for deployment & interaction
│   ├── Attack.s.sol                 # Launches reentrancy attack
│   ├── DeployAttack.s.sol           # Deploys attack contract
│   ├── DeployVault.s.sol            # Deploys vulnerable vault
│   ├── DeployVaultFixed.s.sol       # Deploys fixed vault
│   ├── DepositToVault.s.sol         # Sends ETH to the vault
│   ├── WithdrawFromAttack.s.sol     # Tries to recover ETH from attack contract
│   └── WithdrawFromVault.s.sol      # Legitimate withdrawal from the vault
│
├── test/                            # Unit tests for both versions
│   ├── ReentrancyVaultAttack.t.sol  # Exploit test for vulnerable vault
│   └── ReentrancyVaultFixed.t.sol   # Validation tests for fixed vault
│
├── SecurityReview/                  # Technical write-up
│   └── security-review.md           # Vulnerability analysis and mitigation
│
├── .env                             # Local private keys and RPC config (excluded from git)
├── .env.example                     # Sample environment file
├── .gitignore                       # Files and folders to exclude from version control
├── .gitmodules                      # Git submodules (e.g. forge-std)
├── foundry.toml                     # Foundry project configuration
├── LICENSE                          # License file
└── README.md                        # You are here
```

---

## Testing

- Load the environment variables into your shell:

  ```bash
  export $(grep -v '^#' .env | xargs)
  ```
- Run unit tests:

  ```bash
  forge test
  ```

- Run exploit on Sepolia fork:

  ```bash
  forge script script/Attack.s.sol --fork-url $RPC_URL --private-key $ATTACKER_PRIVATE_KEY --broadcast -vvvv
  ```

---

## Script Usage Guide

Each script file interacts with the vault in a specific way. Below are the correct usage patterns based on the script's purpose and the expected account (user or attacker).

### Deploy Contracts

#### Deploy Vulnerable Vault (by normal user)
```bash
forge script script/DeployVault.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

#### Deploy Fixed Vault (by normal user)
```bash
forge script script/DeployVaultFixed.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

#### Deploy Reentrancy Attack Contract (by attacker)
```bash
forge script script/DeployAttack.s.sol --rpc-url $RPC_URL --private-key $ATTACKER_PRIVATE_KEY --broadcast -vvvv
```

---

### 💸 Vault Interactions

#### Deposit ETH to Vault (by normal user)
```bash
forge script script/DepositToVault.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

#### Legitimate Withdraw from Vault (by normal user)
```bash
forge script script/WithdrawFromVault.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

---

### Exploit

#### Execute Reentrancy Attack (by attacker)
```bash
forge script script/Attack.s.sol --rpc-url $RPC_URL --private-key $ATTACKER_PRIVATE_KEY --broadcast -vvvv
```

#### Withdraw ETH from Attack Contract (by attacker)
```bash
forge script script/WithdrawFromAttack.s.sol --rpc-url $RPC_URL --private-key $ATTACKER_PRIVATE_KEY --broadcast -vvvv
```

---

## Vulnerability Summary

| Detail            | Value                             |
| ----------------- | --------------------------------- |
| Type              | Reentrancy (SWC-107)              |
| Affected Function | `withdraw()`                      |
| Cause             | External call before state update |
| Fix               | Update state before external call |

---

## References

- [SWC Registry - SWC-107](https://swcregistry.io/docs/SWC-107)
- [Solidity Docs - Reentrancy](https://docs.soliditylang.org/en/latest/security-considerations.html#re-entrancy)

---

## Author

Security case by [00xhope](https://x.com/00xhope)