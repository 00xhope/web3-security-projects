
# Security Review: ReentrancyVault

This document analyzes a classic **Reentrancy vulnerability** in a smart contract that manages ETH deposits and withdrawals. The report walks through the root cause, exploit scenario, and proposed fix.

---

## Vulnerability Overview

- **Name**: Reentrancy
- **SWC-ID**: [SWC-107](https://swcregistry.io/docs/SWC-107)
- **Severity**: High
- **Affected Function**: `withdraw()`
- **Impact**: Unauthorized recursive withdrawals

---

## Root Cause

The `withdraw()` function transfers ETH to the caller using `call`, then updates the user's balance:

```solidity
(bool success, ) = payable(msg.sender).call{value: amount}("");
require(success, "Transfer failed");

balances[msg.sender] = 0;
```

This creates a **vulnerable sequence**:
1. ETH is sent (external call to untrusted contract)
2. State is updated only **after** the external call

This allows the external contract to **re-enter** `withdraw()` **before** the balance is reset.

---

## Exploitation Flow

The attacker creates a contract with a `receive()` function that recursively calls `withdraw()`:

```solidity
receive() external payable {
    if (address(vault).balance > 0) {
        vault.withdraw();
    }
}
```

Because the ETH is sent using:

```solidity
(bool success, ) = payable(msg.sender).call{value: amount}("");
```

...and the calldata is empty (`""`), Solidity automatically invokes the attacker's `receive()` function.

This causes repeated calls to `withdraw()` while the original balance is still intact, draining the vault.

---

## `receive()` vs `fallback()`

When ETH is sent to a contract via `call`, Solidity decides which function to trigger:

| Condition                             | Triggered Function |
|--------------------------------------|--------------------|
| Empty calldata + `receive()` exists  | `receive()`        |
| Non-empty calldata                   | `fallback()`       |
| Empty calldata but no `receive()`    | `fallback()`       |

In this case:

- `call{value: amount}("")` is used → calldata is empty
- The attack contract defines a `receive()` function

➡️ Therefore, **`receive()`** is executed, enabling reentrancy.

---

## Remediation

To fix the vulnerability, update the internal state **before** making the external call:

```solidity
uint256 amount = balances[msg.sender];
require(amount > 0, "No balance to withdraw");

balances[msg.sender] = 0;

(bool success, ) = payable(msg.sender).call{value: amount}("");
require(success, "Transfer failed");
```

---

## Additional Mitigations

- Use the **Checks-Effects-Interactions** pattern
- Apply the `ReentrancyGuard` modifier from OpenZeppelin (if suitable)
- Avoid external calls unless necessary

---

## References

- [SWC-107: Reentrancy](https://swcregistry.io/docs/SWC-107)
- [Solidity Docs: Reentrancy](https://docs.soliditylang.org/en/latest/security-considerations.html#re-entrancy)
- [Ethereum Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

## Reviewer

Security case by [00xhope](https://x.com/00xhope)
