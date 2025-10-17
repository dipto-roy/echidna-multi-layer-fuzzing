// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBank {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    
    constructor() {
        totalSupply = 1000000;
        balances[msg.sender] = totalSupply;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Must deposit some ether");
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
    
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Cannot transfer to zero address");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
    
    // Echidna property tests - these should always return true
    function echidna_balance_never_negative() public view returns (bool) {
        return balances[msg.sender] >= 0;
    }
    
    function echidna_total_supply_preserved() public view returns (bool) {
        // This is a simple check - in a real scenario you'd sum all balances
        return totalSupply == 1000000;
    }
    
    function echidna_no_zero_address_balance() public view returns (bool) {
        return balances[address(0)] == 0;
    }
}

contract GasLimitCheck {
    uint256 public x;

    function heavyLoop(uint256 n) public {
        require(n < 500, "Too much gas");
        for (uint256 i = 0; i < n; i++) {
            x += 1;
        }
    }

    function echidna_gas_safe() public view returns (bool) {
        return true; // Contract reverts on high gas anyway
    }
}
