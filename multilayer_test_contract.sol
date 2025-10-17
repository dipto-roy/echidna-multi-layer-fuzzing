// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiLayerTestContract {
    uint256 public balance;
    mapping(address => uint256) public userBalances;
    mapping(address => mapping(address => uint256)) public allowances;
    address public owner;
    uint256 public totalSupply;
    bool public paused;
    
    constructor() {
        owner = msg.sender;
        totalSupply = 1000000 * 10**18;
        balance = totalSupply;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier notPaused() {
        require(!paused, "Contract paused");
        _;
    }
    
    // Priority functions for pre-dilution testing
    function transfer(address to, uint256 amount) public notPaused returns (bool) {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Invalid recipient");
        
        userBalances[msg.sender] -= amount;
        userBalances[to] += amount;
        return true;
    }
    
    function approve(address spender, uint256 amount) public notPaused returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }
    
    function withdraw(uint256 amount) public notPaused {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        require(balance >= amount, "Contract insufficient balance");
        
        userBalances[msg.sender] -= amount;
        balance -= amount;
        // Potential reentrancy vulnerability for testing
        payable(msg.sender).transfer(amount);
    }
    
    function deposit() public payable notPaused {
        require(msg.value > 0, "Must deposit something");
        balance += msg.value;
        userBalances[msg.sender] += msg.value;
    }
    
    function mint(address to, uint256 amount) public onlyOwner notPaused {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Must mint positive amount");
        
        totalSupply += amount;
        userBalances[to] += amount;
        // Bug: No check for overflow in totalSupply
    }
    
    function burn(uint256 amount) public notPaused {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        
        userBalances[msg.sender] -= amount;
        totalSupply -= amount;
        // Bug: No check for underflow in totalSupply
    }
    
    function swap(uint256 amountIn, uint256 minAmountOut) public notPaused returns (uint256) {
        require(amountIn > 0, "Invalid input amount");
        require(userBalances[msg.sender] >= amountIn, "Insufficient balance");
        
        // Simplified swap calculation with potential manipulation
        uint256 amountOut = (amountIn * 95) / 100; // 5% fee
        require(amountOut >= minAmountOut, "Slippage too high");
        
        userBalances[msg.sender] -= amountIn;
        userBalances[msg.sender] += amountOut;
        
        return amountOut;
    }
    
    // Normal functions for differential treatment testing
    function getBalance(address user) public view returns (uint256) {
        return userBalances[user];
    }
    
    function getAllowance(address user, address spender) public view returns (uint256) {
        return allowances[user][spender];
    }
    
    function pause() public onlyOwner {
        paused = true;
    }
    
    function unpause() public onlyOwner {
        paused = false;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
    
    // Complex function for smart mutation testing
    function complexOperation(
        uint256[] memory amounts,
        address[] memory recipients,
        bool[] memory flags
    ) public notPaused {
        require(amounts.length == recipients.length, "Array length mismatch");
        require(amounts.length == flags.length, "Array length mismatch");
        require(amounts.length <= 10, "Too many operations");
        
        for (uint256 i = 0; i < amounts.length; i++) {
            if (flags[i]) {
                require(userBalances[msg.sender] >= amounts[i], "Insufficient balance");
                userBalances[msg.sender] -= amounts[i];
                userBalances[recipients[i]] += amounts[i];
            }
        }
    }
    
    // Echidna properties for multi-layer testing
    function echidna_balance_never_negative() public view returns (bool) {
        return balance >= 0;
    }
    
    function echidna_total_supply_consistency() public view returns (bool) {
        return totalSupply >= 0;
    }
    
    function echidna_user_balance_never_negative() public view returns (bool) {
        return userBalances[msg.sender] >= 0;
    }
    
    function echidna_total_supply_reasonable() public view returns (bool) {
        return totalSupply <= 10**30; // Reasonable upper bound
    }
    
    function echidna_contract_balance_consistency() public view returns (bool) {
        // Contract balance should not exceed total supply
        return balance <= totalSupply;
    }
    
    function echidna_allowance_reasonable() public view returns (bool) {
        return allowances[msg.sender][address(this)] <= totalSupply;
    }
    
    function echidna_owner_not_zero() public view returns (bool) {
        return owner != address(0);
    }
    
    // Property specifically for pre-dilution functions
    function echidna_priority_functions_coverage() public view returns (bool) {
        // This property should be tested more frequently due to pre-dilution
        return userBalances[msg.sender] <= totalSupply;
    }
    
    // Property for differential treatment testing
    function echidna_complex_state_consistency() public view returns (bool) {
        // Complex property that should benefit from longer sequences
        return balance + userBalances[msg.sender] >= 0;
    }
    
    // Edge case property for adaptive fuzzing
    function echidna_edge_case_detection() public view returns (bool) {
        // Property that should trigger adaptive strategy adjustment
        if (paused && userBalances[msg.sender] > 0) {
            return balance > 0;
        }
        return true;
    }
}
