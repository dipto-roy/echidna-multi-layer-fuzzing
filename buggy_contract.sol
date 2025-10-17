// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BuggyContract {
    uint256 public counter;
    mapping(address => uint256) public userCounts;
    address public owner;
    
    constructor() {
        owner = msg.sender;
        counter = 0;
    }
    
    function increment() public {
        counter++;
        userCounts[msg.sender]++;
    }
    
    function decrement() public {
        require(counter > 0, "Counter cannot be negative");
        counter--;
        userCounts[msg.sender]--;
    }
    
    function reset() public {
        require(msg.sender == owner, "Only owner can reset");
        counter = 0;
        // Bug: We don't reset user counts!
    }
    
    function dangerousFunction(uint256 value) public {
        // Bug: This can cause integer overflow in older Solidity versions
        counter += value;
    }
    
    // Echidna properties - these should always return true
    function echidna_counter_never_negative() public view returns (bool) {
        return counter >= 0;
    }
    
    function echidna_user_count_never_negative() public view returns (bool) {
        return userCounts[msg.sender] >= 0;
    }
    
    function echidna_counter_reasonable() public view returns (bool) {
        // This might fail due to the dangerous function
        return counter < 1000000;
    }
    
    function echidna_user_count_matches_increments() public view returns (bool) {
        // This is a simplified check - in practice you'd track this more carefully
        return userCounts[msg.sender] <= counter;
    }
}
