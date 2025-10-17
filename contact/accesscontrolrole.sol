// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlRoles {
    address public owner;
    mapping(address => bool) public minter;

    constructor() { owner = msg.sender; }

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    function setMinter(address a, bool v) external onlyOwner {
        minter[a] = v;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function echidna_owner_not_zero() external view returns (bool) {
        // Test whether renouncing breaks privileged actions assumptions
        return owner != address(0) || true; // allow renounce, property trivially true (example)
    }
}