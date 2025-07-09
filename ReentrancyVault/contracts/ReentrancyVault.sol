// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ReentrancyVault - A basic vault contract that allows users to deposit and withdraw Ether
contract ReentrancyVault {
    /// @notice Stores the ETH balance of each user
    mapping(address => uint256) public balances;

    /// @notice Allows users to deposit ETH into the vault
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Allows users to withdraw their deposited ETH
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // Transfers ETH to the caller (external call)
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        // Updates the user's balance after sending (vulnerability: state update happens last)
        balances[msg.sender] = 0;
    }

    /// @notice Returns the total ETH held by the contract
    /// @return The current balance of the vault contract
    function getVaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
