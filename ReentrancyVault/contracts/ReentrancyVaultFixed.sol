// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ReentrancyVaultFixed - A secure version of the vault contract with reentrancy protection
contract ReentrancyVaultFixed {
    /// @notice Stores the ETH balance of each user
    mapping(address => uint256) public balances;

    /// @notice Allows users to deposit ETH into the vault
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Allows users to safely withdraw their deposited ETH
    /// @dev Uses checks-effects-interactions pattern to prevent reentrancy
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // Effect: update state before external interaction
        balances[msg.sender] = 0;

        // Interaction: send ETH back to the user
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    /// @notice Returns the total ETH held by the contract
    /// @return The current balance of the vault contract
    function getVaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
